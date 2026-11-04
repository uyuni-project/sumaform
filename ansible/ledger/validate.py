"""Ledger validator and markdown generator. See SCHEMA.md.

Usage: validate.py LEDGER.yml [--root REPO] [--md OUT.md]
"""
import argparse
import pathlib
import re
import sys

import yaml

TARGETS = {"role", "playbook", "var", "tf-only", "backend", "dropped",
           "deferred", "n/a-upstream-removed"}
VAR_RE = re.compile(r'^\s*variable\s+"([^"]+)"', re.M)


def pin_vars(root, tf_dirs):
    """Variables at the pin: ids are '<dir of variables.tf rel. to root>:<name>'."""
    out = set()
    for d in tf_dirs:
        for f in (root / d).rglob("variables.tf"):
            rel = f.parent.relative_to(root).as_posix()
            out |= {f"{rel}:{n}" for n in VAR_RE.findall(f.read_text())}
    return out


def salt_paths(root, salt_dir):
    return [p.relative_to(root).as_posix()
            for p in (root / salt_dir).rglob("*") if p.is_file()]


def cited(path, citations):
    return any(path == c or (c.endswith("/") and path.startswith(c)) for c in citations)


def validate(ledger, root=".", tf_dirs=("modules", "backend_modules"), salt_dir="salt"):
    root = pathlib.Path(root)
    led = yaml.safe_load(pathlib.Path(ledger).read_text()) or {}
    errs = []
    hr = led.get("host_roles") or []
    playbooks = {h.get("playbook") for h in hr}
    roles = {r for h in hr for r in h.get("roles") or []}
    vrows = led.get("variables") or []
    brows = led.get("behaviours") or []

    for kind, rows in (("variable", vrows), ("behaviour", brows)):
        for r in rows:
            rid, t = r.get("id", "?"), r.get("target")
            if not t:
                errs.append(f"{kind} {rid}: blank target")
                continue
            if t not in TARGETS:
                errs.append(f"{kind} {rid}: unknown target {t!r}")
            if not r.get("since_pin"):
                errs.append(f"{kind} {rid}: missing since_pin")
            if t in ("dropped", "deferred") and not r.get("reason"):
                errs.append(f"{kind} {rid}: {t} without reason")
            if t == "dropped" and not r.get("signoff"):
                errs.append(f"{kind} {rid}: dropped without signoff")
            if t == "playbook" and r.get("ref") not in playbooks:
                errs.append(f"{kind} {rid}: playbook {r.get('ref')!r} not in host_roles")
            if t == "role" and r.get("ref") not in roles:
                errs.append(f"{kind} {rid}: role {r.get('ref')!r} not in host_roles")
            # ponytail: `verified` is allowed but not enforced here (ticket #128).

    have = pin_vars(root, tf_dirs)
    ids = {r.get("id") for r in vrows}
    errs += [f"variable {v}: no row" for v in sorted(have - ids)]
    errs += [f"variable {v}: row names variable not in pin" for v in sorted(ids - have)]
    cites = [p for r in brows for p in r.get("paths") or []]
    errs += [f"salt path {p}: uncited by any behaviour row"
             for p in sorted(salt_paths(root, salt_dir)) if not cited(p, cites)]
    return errs


def markdown(ledger):
    led = yaml.safe_load(pathlib.Path(ledger).read_text()) or {}
    cell = lambda v: "" if v is None else str(v).replace("|", "\\|")
    out = [f"# Ledger (pin {led.get('pin')})", ""]
    for title, key, cols in (
        ("Variables", "variables", ["id", "target", "ref", "reason", "signoff", "since_pin", "verified"]),
        ("Behaviours", "behaviours", ["id", "paths", "target", "ref", "reason", "signoff", "since_pin", "verified"]),
        ("Host roles", "host_roles", ["id", "playbook", "roles"]),
    ):
        out += [f"## {title}", "", "| " + " | ".join(cols) + " |", "|" + "---|" * len(cols)]
        out += ["| " + " | ".join(cell(r.get(c)) for c in cols) + " |" for r in led.get(key) or []]
        out.append("")
    return "\n".join(out)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("ledger")
    ap.add_argument("--root", default=".")
    ap.add_argument("--md")
    a = ap.parse_args()
    if a.md:
        pathlib.Path(a.md).write_text(markdown(a.ledger))
    e = validate(a.ledger, a.root)
    print("\n".join(e) or "ok")
    sys.exit(1 if e else 0)

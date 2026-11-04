"""Ledger validator and markdown generator. See SCHEMA.md.

Usage: validate.py LEDGER.yml [--root REPO] [--md OUT.md] [--require-verified] [--deletion-gate]
"""
import argparse
import json
import pathlib
import re
import sys

import yaml

RUN_LEVEL = {"host-state-diff": 2, "compare-runs": 3}  # default level a run proves
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


def load_runs(ledger):
    """Run files live in runs/<id>.json next to the ledger."""
    d = pathlib.Path(ledger).parent / "runs"
    files = sorted(d.glob("*.json")) if d.is_dir() else []
    return {r["id"]: r for r in (json.loads(f.read_text()) for f in files)}


def min_level(kind, row):
    """Minimum verified level by row kind (spec: Verification)."""
    if kind == "host_role":
        return 3
    if row.get("target") in ("tf-only", "backend"):
        return 1
    if kind == "behaviour" and row.get("changes_state") is False:
        return 1
    return 2


def pin_current(vpin, rid, led):
    """True if vpin is the ledger pin, or a re-pin chain from vpin to it never touched rid."""
    seen = set()
    while vpin != led.get("pin"):
        step = next((r for r in led.get("repins") or [] if isinstance(r, dict) and r.get("from") == vpin), None)
        if not step or vpin in seen or rid in (step.get("touched") or []):
            return False
        seen.add(vpin)
        vpin = step.get("to")
    return True


def check_verified(kind, row, led, runs):
    """Errors for one row's `verified` claim (empty list = proof holds)."""
    rid, v = row.get("id", "?"), row.get("verified")
    where = f"{kind} {rid}"
    if not isinstance(v, dict):
        return [f"{where}: verified missing"]
    lvl, run = v.get("level"), runs.get(v.get("evidence"))
    errs = []
    if lvl not in (1, 2, 3, 4):
        return [f"{where}: verified level {lvl!r} not in 1-4"]
    if lvl < min_level(kind, row):
        errs.append(f"{where}: verified level {lvl} below minimum {min_level(kind, row)}")
    if not pin_current(v.get("pin"), rid, led):
        errs.append(f"{where}: verified pin {v.get('pin')!r} is stale")
    if not run:
        return errs + [f"{where}: verified cites missing run {v.get('evidence')!r}"]
    if run.get("pin") != v.get("pin"):
        errs.append(f"{where}: run {run['id']} pin {run.get('pin')!r} != verified pin")
    if rid not in (run.get("rows_covered") or []):
        errs.append(f"{where}: run {run['id']} does not cover it")
    if run.get("result") != "pass":
        errs.append(f"{where}: run {run['id']} result is {run.get('result')!r}")
    if lvl > run.get("level", RUN_LEVEL.get(run.get("kind"), 0)):
        errs.append(f"{where}: run {run['id']} proves less than level {lvl}")
    if (kind == "variable" and lvl >= 2 and row.get("target") not in ("tf-only", "backend")
            and rid not in (run.get("non_default") or [])):
        errs.append(f"{where}: run {run['id']} shows no non-default value")
    return errs


def validate(ledger, root=".", tf_dirs=("modules", "backend_modules"), salt_dir="salt",
             require_verified=False, deletion_gate=False):
    root = pathlib.Path(root)
    led = yaml.safe_load(pathlib.Path(ledger).read_text()) or {}
    errs = []
    hr = led.get("host_roles") or []
    playbooks = {h.get("playbook") for h in hr}
    roles = {r for h in hr for r in h.get("roles") or []}
    vrows = led.get("variables") or []
    known_pins = {led.get("pin"), "post-pin"} | {
        p for r in led.get("repins") or [] if isinstance(r, dict) for p in (r.get("from"), r.get("to"))}
    brows = led.get("behaviours") or []

    for kind, rows in (("variable", vrows), ("behaviour", brows)):
        for r in rows:
            rid, t = r.get("id", "?"), r.get("target")
            if not t:
                errs.append(f"{kind} {rid}: blank target")
                continue
            if t not in TARGETS:
                errs.append(f"{kind} {rid}: unknown target {t!r}")
            sp = r.get("since_pin")
            if not sp:
                errs.append(f"{kind} {rid}: missing since_pin")
            elif sp not in known_pins:
                errs.append(f"{kind} {rid}: since_pin {sp!r} is not the pin, a repin pin or 'post-pin'")
            if t in ("dropped", "deferred") and not r.get("reason"):
                errs.append(f"{kind} {rid}: {t} without reason")
            if t == "dropped" and not r.get("signoff"):
                errs.append(f"{kind} {rid}: dropped without signoff")
            if t == "playbook" and r.get("ref") not in playbooks:
                errs.append(f"{kind} {rid}: playbook {r.get('ref')!r} not in host_roles")
            if t == "role" and r.get("ref") not in roles:
                errs.append(f"{kind} {rid}: role {r.get('ref')!r} not in host_roles")
            if t == "deferred" and deletion_gate:
                errs.append(f"{kind} {rid}: deferred blocks Salt deletion (re-sign as dropped)")

    runs = load_runs(ledger)
    skip = ("dropped", "deferred", "n/a-upstream-removed")
    for kind, rows in (("variable", vrows), ("behaviour", brows), ("host_role", hr)):
        for r in rows:
            if r.get("verified") is not None or (require_verified and r.get("target") not in skip):
                errs += check_verified(kind, r, led, runs)

    have = pin_vars(root, tf_dirs)
    ids = {r.get("id") for r in vrows}
    errs += [f"variable {v}: no row" for v in sorted(have - ids)]
    errs += [f"variable {v}: row names variable not in pin" for v in sorted(ids - have)]
    cites = [p for r in brows for p in r.get("paths") or []]
    errs += [f"salt path {p}: uncited by any behaviour row"
             for p in sorted(salt_paths(root, salt_dir)) if not cited(p, cites)]
    return errs


def pending(ledger):
    """Ids of dropped rows whose signoff is the literal PENDING (not an error)."""
    led = yaml.safe_load(pathlib.Path(ledger).read_text()) or {}
    return [r.get("id") for k in ("variables", "behaviours") for r in led.get(k) or []
            if r.get("signoff") == "PENDING"]


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
    ap.add_argument("--require-verified", action="store_true")
    ap.add_argument("--deletion-gate", action="store_true")
    a = ap.parse_args()
    if a.md:
        pathlib.Path(a.md).write_text(markdown(a.ledger))
    e = validate(a.ledger, a.root, require_verified=a.require_verified, deletion_gate=a.deletion_gate)
    print("\n".join(e) or "ok")
    print(f"pending sign-off: {len(pending(a.ledger))}")
    sys.exit(1 if e else 0)

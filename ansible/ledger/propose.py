"""Print proposed `verified` updates from runs/*.json. Never edits the ledger.

Usage: propose.py LEDGER.yml
"""
import pathlib
import sys

import yaml

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import validate  # noqa: E402


def propose(ledger):
    """[(row id, verified dict)] for rows where a valid run beats the current valid proof."""
    led = yaml.safe_load(pathlib.Path(ledger).read_text()) or {}
    runs = validate.load_runs(ledger)
    out = []
    for kind, key in (("variable", "variables"), ("behaviour", "behaviours"), ("host_role", "host_roles")):
        for row in led.get(key) or []:
            cur = row.get("verified")
            floor = cur["level"] if cur and not validate.check_verified(kind, row, led, runs) else 0
            best = None
            for run in runs.values():
                lvl = run.get("level", validate.RUN_LEVEL.get(run.get("kind"), 0))
                v = {"level": lvl, "evidence": run["id"], "pin": led.get("pin")}
                if lvl > max(floor, best["level"] if best else 0) \
                        and not validate.check_verified(kind, dict(row, verified=v), led, runs):
                    best = v
            if best:
                out.append((row.get("id"), best))
    return out


if __name__ == "__main__":
    props = propose(sys.argv[1])
    for rid, v in props:
        print(f"{rid}: {{level: {v['level']}, evidence: {v['evidence']}, pin: {v['pin']}}}")
    print(f"# {len(props)} proposed update(s); paste into the ledger after review", file=sys.stderr)

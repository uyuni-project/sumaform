# Ledger schema

YAML is the source of truth; markdown is generated (`validate.py LEDGER --md OUT`).
Validate: `python3 ansible/ledger/validate.py ledger.yml --root .` (exit 1 on errors).
Test: `python3 -m pytest ansible/ledger/tests`.

```yaml
pin: d0c6e082              # upstream commit; variables.tf files in the tree at HEAD are the pin
variables:                 # one row per `variable "x"` in modules/** and backend_modules/**
  - {id: "modules/base:name", target: var, ref: "...", since_pin: d0c6e082}
behaviours:                # grains, custom states, wrapper scripts, hooks
  - {id: x, paths: [salt/foo/, salt/bar.sls], target: playbook, ref: minion.yml, since_pin: d0c6e082}
host_roles:                # Terraform `roles` grain -> playbook -> ordered Ansible roles
  - {id: minion, playbook: minion.yml, roles: [base, minion]}
repins: []                 # free-form for now (ported / skipped / n/a row ids)
```

- Variable id: `<dir of variables.tf relative to repo root>:<name>`.
- `target` (closed set): role, playbook, var, tf-only, backend, dropped, deferred, n/a-upstream-removed.
  - `role` / `playbook`: `ref` must appear in `host_roles` (roles list / playbook).
  - `dropped`: `reason` and `signoff` required; `signoff: PENDING` is reported as pending, not an error. `deferred`: `reason` required.
- `since_pin`: required on every row (pin at which the row was added); lets deltas be computed. Allowed values: the ledger `pin`, a `from`/`to` of a `repins` entry, or the sentinel `post-pin` for rows whose variable or behaviour was added to this fork after the pin (e.g. `provisioner`); a re-pin replaces `post-pin` with the new pin.
- `paths` (behaviours): salt files, or a directory with trailing `/` citing everything below it. Every file under `salt/` must be cited.
- `verified: {level, evidence, pin}` (variables, behaviours, host_roles; optional). Levels: 1 static, 2 paired deploy + host-state diff, 3 smoke subset, 4 full acceptance. Checked when present, or on every non-dropped/deferred/n-a row with `--require-verified`. A claim fails if: level not 1-4, below the row minimum, `evidence` names no `runs/<id>.json`, the run's pin differs from `verified.pin`, the run does not list the row, the run result is not `pass`, the run proves less than the claimed level, or the pin is stale.
  - Minimums: variables 2 (the run must list the id in `non_default`), behaviours 2 (1 if `changes_state: false`), host roles 3, `tf-only`/`backend` 1. `dropped` is proven by reason + signoff, `deferred` has no proof; `--deletion-gate` fails on any `deferred` row.
  - Stale: `verified.pin` must equal the ledger `pin`, or a chain of `repins` entries must lead from it to the ledger pin without touching the row.
- `repins`: `[{from: <old pin>, to: <new pin>, touched: [row ids], ported: [...], skipped: [...], na: [...]}]`. Only `from`, `to`, `touched` are read; `verified` on a touched row goes stale until re-proven at the new pin. Untouched rows stay valid.
- Runs: `ansible/ledger/runs/<id>.json`, written from a read-only host-state SSH capture or a compare-runs report (by hand or tooling, never in the ledger):
  `{"id": "run-1", "pin": "abc123", "kind": "host-state-diff|compare-runs", "rows_covered": ["row id"], "result": "pass|fail", "non_default": ["variable ids shown taking effect"], "level": 2}`.
  `non_default` and `level` are optional; `level` defaults to 2 for host-state-diff and 3 for compare-runs (set 4 for a full acceptance run).
- `propose.py LEDGER.yml`: prints proposed `verified` entries from passing runs that the validator would accept and that raise the row's level. Never edits the ledger; paste in one reviewed batch.

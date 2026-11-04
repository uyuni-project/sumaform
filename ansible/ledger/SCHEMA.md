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
- `since_pin`: required on every row (pin at which the row was added); lets deltas be computed.
- `paths` (behaviours): salt files, or a directory with trailing `/` citing everything below it. Every file under `salt/` must be cited.
- `verified: {level, evidence, pin}`: optional, accepted and not enforced yet (#128).

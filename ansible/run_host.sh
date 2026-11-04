#!/bin/bash
# One Ansible run for one host, triggered from Terraform (local-exec).
# Env: HOST_JSON (one-element list, see inventory.py), SUMAFORM_VM_PASSWORD (optional),
#      BUILD_NUMBER (per-build dirs, as in worker/preflight.sh).
set -eu
umask 077  # per-build and scratch dirs 0700, files 0600
here=$(cd "$(dirname "$0")" && pwd)
base="${TMPDIR:-/tmp}/ansible-build-${BUILD_NUMBER:-$$-$RANDOM}"
mkdir -p "$base/home" "$base/local" "$base/remote"
export ANSIBLE_HOME="$base/home" ANSIBLE_LOCAL_TEMP="$base/local" ANSIBLE_REMOTE_TEMP="$base/remote"
export ANSIBLE_CONFIG="$here/ansible.cfg"

work=$(mktemp -d "$base/host.XXXXXX")
trap 'rm -rf "$work"' EXIT
printf '%s' "$HOST_JSON" > "$work/hosts.json"
python3 "$here/inventory.py" "$work/hosts.json" "$work/inv"

name=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))[0]["name"])' "$work/hosts.json")
roles=$(python3 -c 'import json,sys; print(*json.load(open(sys.argv[1]))[0]["roles"])' "$work/hosts.json")
# ponytail: one playbook per host role, run in sequence; a combined playbook is needed once multi-role hosts are ported
for role in $roles; do
    ansible-playbook -i "$work/inv/hosts.yml" --limit "$name" "$here/playbooks/$role.yml"
done

#!/bin/bash
# Worker preflight: ansible version, port 22 per site, ansible ping.
# Usage: preflight.sh <host-or-site> [<host-or-site> ...]
# Env: BUILD_NUMBER (per-build dirs; else a unique tmp dir), PORT_CHECK (cmd: $1=host, $2=port).
set -u

[ $# -ge 1 ] || { echo "usage: $0 <host> [<host> ...]" >&2; exit 2; }

port_open() { timeout 5 bash -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null; }
fail() { echo "PREFLIGHT FAILED: $*" >&2; exit 1; }

# Per-build isolation so concurrent builds on one worker do not collide.
base="${TMPDIR:-/tmp}/ansible-build-${BUILD_NUMBER:-$$-$RANDOM}"
mkdir -p "$base/home" "$base/local" "$base/remote" || fail "cannot create $base"
export ANSIBLE_HOME="$base/home" ANSIBLE_LOCAL_TEMP="$base/local" ANSIBLE_REMOTE_TEMP="$base/remote"

command -v ansible >/dev/null || fail "ansible not found in PATH"
ansible --version | head -1 || fail "ansible --version failed"

for h in "$@"; do
    if [ -n "${PORT_CHECK:-}" ]; then "$PORT_CHECK" "$h" 22; else port_open "$h" 22; fi \
        || fail "port 22 unreachable on $h"
done

inv=$(IFS=,; echo "$*,")
ansible -i "$inv" all -m ping || fail "ansible ping failed for: $*"
echo "preflight OK ($*), ANSIBLE_HOME=$ANSIBLE_HOME"

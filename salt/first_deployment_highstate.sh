#!/bin/bash

# Applies the "minimal" state in isolation to set the hostname and update Salt itself
# then applies the highstate

FILE_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

salt-call --local --file-root=$FILE_ROOT/ --log-level=quiet --output=quiet state.sls default.minimal ||:
salt-call --local --file-root=$FILE_ROOT/ --log-level=info --retcode-passthrough --force-color state.highstate || exit 1

chmod +x ${FILE_ROOT}/highstate.sh

#!/bin/bash

# Applies the highstate - assumes the minimal state was already applied
FILE_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

salt-call --local --file-root=$FILE_ROOT/ --log-level=info --retcode-passthrough --force-color state.highstate

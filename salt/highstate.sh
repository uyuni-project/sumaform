#!/bin/bash

# Applies the highstate - assumes the minimal state was already applied
FILE_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ -x /usr/bin/venv-salt-call ]; then
    SALT_CALL=venv-salt-call
elif [ -x /usr/bin/salt-call ]; then
    SALT_CALL=salt-call
else
    echo "Error: Cannot find venv-salt-call or salt-call on the system"
    exit 1
fi

${SALT_CALL} --local --file-root=$FILE_ROOT/ --log-level=info --out-file=/var/log/salt-deployment.log --retcode-passthrough --force-color state.highstate

# Display the output from the Salt execution
cat /var/log/salt-deployment.log

#!/bin/bash

# Applies the "minimal" state in isolation to set the hostname and update Salt itself
# then applies the highstate

FILE_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ -x /usr/bin/venv-salt-call ]; then
    echo "Salt Bundle detected! We use it for running sumaform deployment"
    echo "Copying /etc/salt/grains to /etc/venv-salt-minion"
    cp /etc/salt/grains /etc/venv-salt-minion/grains
    SALT_CALL=venv-salt-call
elif [ -x /usr/bin/salt-call ]; then
    SALT_CALL=salt-call
else
    echo "Error: Cannot find venv-salt-call or salt-call on the system"
    exit 1
fi

# Force direct call module executors on MicroOS images
MODULE_EXEC=""
if grep -q "cpe:/o:.*suse:.*micro" /etc/os-release; then
MODULE_EXEC="--module-executors=[direct_call]"
fi

echo "starting first call to update salt and do minimal configuration"

$SALT_CALL --local --file-root=$FILE_ROOT/ --log-level=info $MODULE_EXEC state.sls default.minimal ||:

NEXT_TRY=0
until [ $NEXT_TRY -eq 10 ] || $SALT_CALL --local test.ping
do
        echo "It seems neither venv-salt-call or salt-call are available after default.minimal state was applied. Retrying... [$NEXT_TRY]";
        sleep 1;
        ((NEXT_TRY++));
done

if [ $NEXT_TRY -eq 10 ]
then
        echo "ERROR: Neither venv-salt-call or salt-call are available after 10 retries";
fi

echo "apply highstate"

$SALT_CALL --local --file-root=$FILE_ROOT/ --log-level=info --retcode-passthrough --force-color $MODULE_EXEC state.highstate || exit 1

chmod +x ${FILE_ROOT}/highstate.sh

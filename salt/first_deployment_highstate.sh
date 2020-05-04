#!/bin/bash

# Applies the "minimal" state in isolation to set the hostname and update Salt itself
# then applies the highstate

FILE_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

salt-call --local --file-root=$FILE_ROOT/ --log-level=quiet --output=quiet state.sls default.minimal ||:

NEXT_TRY=0
until [ $NEXT_TRY -eq 10 ] || salt-call --version
do
        echo "It seems salt-call is not available after default.minimal state was applied. Retrying... [$NEXT_TRY]";
        sleep 1;
        ((NEXT_TRY++));
done

if [ $NEXT_TRY -eq 10 ]
then
        echo "ERROR: salt-call is not available after 10 retries";
        exit 1;
fi

salt-call --local --file-root=$FILE_ROOT/ --log-level=info --retcode-passthrough --force-color state.highstate || exit 1

chmod +x ${FILE_ROOT}/highstate.sh

#!/bin/bash

if [ -x /usr/bin/venv-salt-call ]; then
    SALT_CALL=venv-salt-call
elif [ -x /usr/bin/salt-call ]; then
    SALT_CALL=salt-call
else
    echo "Error: Cannot find venv-salt-call or salt-call on the system"
    exit 1
fi

# As Salt might be in the process of being installed by cloud-init, this script waits for it

for i in {0..100}
do
  if $SALT_CALL --help &>/dev/null; then
    break
  fi
  echo "Waiting for salt to be installed..."
  sleep 3
done

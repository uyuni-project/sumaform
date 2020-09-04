#!/bin/bash

# As Salt might be in the process of being installed by cloud-init, this script waits for it

for i in {0..100}
do
  if [[ `salt-call --help` ]]; then
    break
  fi
  echo "Waiting for salt to be installed..."
  sleep 3
done

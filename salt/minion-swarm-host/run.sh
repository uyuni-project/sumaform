#!/bin/bash

MASTER=$(salt-call grains.get server --output text | awk '{print $2}' | xargs echo -n)
echo -e "master: $MASTER\n" > master.conf
MASTER_IP=$(cat /etc/hosts | grep $MASTER | awk '{print $1}' | xargs echo -n)
ARGS=""
if [ ! -z "$MASTER" ]; then
    ARGS="--add-host $MASTER:$MASTER_IP"
fi

for i in `seq 1 10`; do
    echo "Container $i"
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1 > minion$i-id
    sudo docker run -d --hostname minion$i --name minion$i -v $PWD/minion$i-id:/etc/machine-id -v $PWD/master.conf:/etc/salt/minion.d/master.conf $ARGS minion
done

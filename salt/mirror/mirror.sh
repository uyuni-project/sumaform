#!/bin/bash
set -e
set -x

cd /srv/mirror
minima -c /root/minima.yaml sync 2>&1 | tee /var/log/minima.log
/root/refresh_scc_data.py {{ grains.get("cc_username") }}:{{ grains.get("cc_password") }}

apt-mirror

chmod -R 777 .

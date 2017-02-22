#!/bin/bash
set -x

cd /srv/mirror
lftp -f /root/mirror.lftp >/var/log/lftp.log 2>/var/log/lftp.err
/root/refresh_scc_data.py {{ grains.get("cc_username") }}:{{ grains.get("cc_password") }}

chmod -R 777 .

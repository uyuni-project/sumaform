#!/bin/bash
set -x

# HACK: workaround for https://infra.nue.suse.com/SelfService/Display.html?id=49948
ping -c 1 euklid.suse.de

cd /srv/mirror
lftp -f /root/mirror.lftp >/var/log/lftp.log 2>/var/log/lftp.err
/root/refresh_scc_data.py {{ grains.get("cc_username") }}:{{ grains.get("cc_password") }}

chmod -R 777 .

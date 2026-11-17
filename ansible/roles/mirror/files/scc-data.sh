#! /bin/bash

/usr/bin/date >> /var/log/scc-data.log
echo '---------------------------------------------------------' >> /var/log/scc-data.log
cd /srv/mirror
SCC_CREDS="$(cat /etc/scc-data.conf)"
(/usr/local/bin/utils/refresh_scc_data.py $SCC_CREDS 2>&1) >> /var/log/scc-data.log
echo >> /var/log/scc-data.log

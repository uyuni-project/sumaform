#! /bin/bash

/usr/bin/date >> /var/log/minima.log
echo '---------------------------------------------------------' >> /var/log/minima.log
(/usr/local/bin/utils/minima sync -c /etc/minima.yaml 2>&1) >> /var/log/minima.log
(/usr/local/bin/utils/jdupes --link-hard -r -s /srv/mirror/ 2>&1) >> /var/log/minima.log
(/usr/local/bin/utils/adjust_external_repos 2>&1) >> /var/log/minima.log
echo >> /var/log/minima.log

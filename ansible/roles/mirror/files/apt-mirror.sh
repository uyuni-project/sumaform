#! /bin/bash

/usr/bin/date >> /var/log/apt-mirror.log
echo '---------------------------------------------------------' >> /var/log/apt-mirror.log
(apt-mirror 2>&1) >> /var/log/apt-mirror.log
(bash /var/spool/apt-mirror/var/clean.sh 2>&1) >> /var/log/apt-mirror.log
echo >> /var/log/apt-mirror.log

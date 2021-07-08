#! /bin/bash

/usr/bin/date >> /var/log/mirror-images.log
echo '---------------------------------------------------------' >> /var/log/mirror-images.log
cd /srv/mirror
for IMAGE in $(cat /etc/mirror-images.conf); do
  echo "${IMAGE}:" >> /var/log/mirror-images.log
  (wget --mirror --no-host-directories ${IMAGE} 2>&1) >> /var/log/mirror-images.log
  echo >> /var/log/mirror-images.log
done
echo >> /var/log/mirror-images.log

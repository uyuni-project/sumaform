#! /bin/bash
  
/usr/bin/date >> /var/log/docker-images.log
echo '---------------------------------------------------------' >> /var/log/docker-images.log
(/usr/local/bin/utils/docker_images /etc/docker-images.conf 2>&1) >> /var/log/docker-images.log
echo >> /var/log/docker-images.log

#! /bin/bash
  
/usr/bin/date >> /var/log/docker_images.log
echo '---------------------------------------------------------' >> /var/log/docker_images.log
(/usr/local/bin/utils/docker_images /etc/docker-images.conf 2>&1) >> /var/log/docker_images.log
echo >> /var/log/docker_images.log

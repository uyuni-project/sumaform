#! /bin/bash

# Remember to export your OpenStack credentials
# Customize these and rename it to upload_images_to_glance.sh
export OS_USERNAME=dmaiocchi
export OS_PASSWORD=dmaiocchi
export OS_PROJECT_ID=dmaiocchi
export OS_AUTH_URL=http://10.162.207.2:5000/v2.0/
IMAGE_PREFIX="dma"
WORKDIR="/tmp"

cd $WORKDIR
wget -c http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2

glance  --os-image-api-version 2 --insecure image-create --name="$IMAGE_PREFIX_sles12sp3" --disk-format=qcow2 --container-format=bare --file sles12sp3.x86_64.qcow2

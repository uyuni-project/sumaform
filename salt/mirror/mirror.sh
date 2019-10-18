#!/bin/bash
set -e
set -x

cd /srv/mirror
minima -c /root/minima.yaml sync 2>&1 | tee /var/log/minima.log
/root/refresh_scc_data.py {{ grains.get("cc_username") }}:{{ grains.get("cc_password") }}

apt-mirror

# will mirror them in /srv/mirror under the same path as the URL
wget --mirror --no-host-directories "https://github.com/moio/sumaform-images/releases/download/4.3.0/centos7.qcow2"
wget --mirror --no-host-directories "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse150.x86_64.qcow2"
wget --mirror --no-host-directories "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse151.x86_64.qcow2"
wget --mirror --no-host-directories "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15.x86_64.qcow2"
wget --mirror --no-host-directories "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15sp1.x86_64.qcow2"
wget --mirror --no-host-directories "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
wget --mirror --no-host-directories "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
wget --mirror --no-host-directories "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
wget --mirror --no-host-directories "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp2.x86_64.qcow2"
wget --mirror --no-host-directories "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2"
wget --mirror --no-host-directories "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp4.x86_64.qcow2"
wget --mirror --no-host-directories "https://github.com/moio/sumaform-images/releases/download/4.3.0/ubuntu1804.qcow2"

jdupes --linkhard -r -s /srv/mirror/

chmod -R 777 .

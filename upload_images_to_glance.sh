#! /bin/bash

# Remember to export your OpenStack credentials

cd /tmp
wget http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles11sp3/images/sles11sp3.x86_64-3.2.0-Build2.2.qcow2
wget http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles11sp4/images/sles11sp4.x86_64-3.2.0-Build2.1.qcow2
wget http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles12/images/sles12.x86_64.qcow2
wget http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles12sp1/images/sles12sp1.x86_64.qcow2

for i in *.qcow2; do glance image-create --name ${i%%.*} --disk-format=qcow2 --container-format=bare --visibility=public --file $i; done

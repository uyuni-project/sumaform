#!/bin/bash
set -e
set -x

cd /srv/mirror
minima -c /root/minima.yaml sync 2>&1 | tee /var/log/minima.log
/root/refresh_scc_data.py {{ grains.get("cc_username") }}:{{ grains.get("cc_password") }}

apt-mirror

# check for nvidia repo and create links, if necessary
if [ -d suse ]; then
  mkdir -p RPMMD
  for dir in suse/sle* ; do
    d=${dir^^}
    ver=${d#SUSE/SLE}
    if [[ $ver == ${ver%SP*} ]]; then
      target="${ver}-GA"
    else
      target=${ver/SP/-SP}
    fi
    full_path=RPMMD/${target}-Desktop-NVIDIA-Driver
    if [ ! -e ${full_path} ]; then
      ln -s ../suse/$dir ${full_path}
    fi
  done
fi

jdupes --linkhard -r -s /srv/mirror/

#chmod -R 777 .

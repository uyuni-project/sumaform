include:
  - package-mirror.repos

lftp:
  pkg.installed:
    - version: '>=4.6.4-1.1'
    - require:
      - sls: package-mirror.repos

lftp-script:
  file.managed:
    - name: /root/mirror.lftp
    - source: salt://package-mirror/mirror.lftp

scc-data-refresh-script:
  file.managed:
    - name: /root/refresh_scc_data.py
    - source: salt://package-mirror/refresh_scc_data.py
    - mode: 755

mirror-script:
  file.managed:
    - name: /root/mirror.sh
    - source: salt://package-mirror/mirror.sh
    - mode: 755
    - template: jinja
  cron.present:
    - name: /root/mirror.sh
    - identifier: PACKAGE_MIRROR
    - user: root
    - hour: 20
    - minute: 0
    - require:
      - file: mirror-script
      - file: lftp-script
      - pkg: lftp

mirror-partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev//{{grains['data_disk_device']}} mkpart primary 2048 100% && /sbin/mkfs.ext4 /dev//{{grains['data_disk_device']}}1
    - unless: ls /dev//{{grains['data_disk_device']}}1

# http serving of mirrored packages
fstab:
  file.managed:
    - name: /etc/fstab

mirror-directory:
  file.directory:
    - name: /srv/mirror
    - user: wwwrun
    - group: users
    - mode: 755
    - makedirs: True
  mount.mounted:
    - name: /srv/mirror
    - device: /dev//{{grains['data_disk_device']}}1
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: mirror-partition

web-server:
  pkg.installed:
    - name: apache2
    - require:
      - sls: package-mirror.repos
  file.managed:
    - name: /etc/apache2/vhosts.d/package-mirror.conf
    - source: salt://package-mirror/package-mirror.conf
    - require:
      - pkg: apache2
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache2
      - file: /etc/apache2/vhosts.d/package-mirror.conf
      - file: mirror-directory
    - watch:
      - file: /etc/apache2/vhosts.d/package-mirror.conf

# NFS serving of mirrored packages

exports-file:
  file.append:
    - name: /etc/exports
    - text: /srv/mirror *(ro,sync,no_root_squash)
    - require:
      - file: mirror-directory

rpcbind:
  service.running:
    - enable: True

nfs:
  service.running:
    - enable: True
    - require:
      - service: rpcbind

nfsserver:
  service.running:
    - enable: True
    - require:
      - file: exports-file
      - service: nfs
    - watch:
      - file: exports-file

# symlinks to mimic SMT's folder structure, which is used by the from-dir
# setting in SUSE Manager

/srv/mirror/repo/$RCE/SLES11-SP3-Pool/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/zypp-patches.suse.de/x86_64/update/SLE-SERVER/11-SP3-POOL/
    - force: True

/srv/mirror/repo/$RCE/SLES11-SP3-Updates/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP3/x86_64/update/
    - force: True

/srv/mirror/repo/$RCE/SLES11-SP4-Pool/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/zypp-patches.suse.de/x86_64/update/SLE-SERVER/11-SP4-POOL/
    - force: True

/srv/mirror/repo/$RCE/SLES11-SP4-Updates/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4/x86_64/update/
    - force: True

/srv/mirror/repo/$RCE/SLES11-SP3-SUSE-Manager-Tools/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP3-CLIENT-TOOLS/x86_64/update/
    - force: True

/srv/mirror/repo/$RCE/SLES11-SP4-SUSE-Manager-Tools/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4-CLIENT-TOOLS/x86_64/update/
    - force: True

/srv/mirror/repo/$RCE/SUSE-Manager-Server-2.1-Pool/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/zypp-patches.suse.de/x86_64/update/SUSE-MANAGER/2.1-POOL/
    - force: True

/srv/mirror/repo/$RCE/SUSE-Manager-Server-2.1-Updates/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SUSE-MANAGER/2.1/x86_64/update/
    - force: True

/srv/mirror/repo/$RCE/SUSE-Manager-Proxy-2.1-Pool/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/zypp-patches.suse.de/x86_64/update/SUSE-MANAGER-PROXY/2.1-POOL/
    - force: True

/srv/mirror/repo/$RCE/SUSE-Manager-Proxy-2.1-Updates/sle-11-x86_64:
  file.symlink:
    - target: ../../../mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SUSE-MANAGER-PROXY/2.1/x86_64/update/
    - force: True

/srv/mirror/SUSE:
  file.symlink:
    - target: mirror/SuSE/build.suse.de/SUSE
    - force: True

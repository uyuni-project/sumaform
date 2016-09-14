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

suse-symlink:
  file.symlink:
    - name: /srv/mirror/SUSE
    - target: mirror/SuSE/build.suse.de/SUSE

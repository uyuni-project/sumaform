include:
  - package-mirror.repos

lftp:
  pkg.installed:
    - version: '>=4.6.4-1.1'
    - require:
      - sls: package-mirror.repos

/root/mirror.lftp:
  file.managed:
    - source: salt://package-mirror/mirror.lftp

/root/refresh_scc_data.py:
  file.managed:
    - source: salt://package-mirror/refresh_scc_data.py
    - mode: 755

/root/mirror.sh:
  file.managed:
    - source: salt://package-mirror/mirror.sh
    - mode: 755
  cron.present:
    - identifier: PACKAGE_MIRROR
    - user: root
    - hour: 20
    - minute: 0
    - require:
      - file: /root/mirror.sh
      - file: /root/mirror.lftp
      - pkg: lftp

vdb1.device:
    cmd.run:
      - name: /usr/sbin/parted -s /dev/vdb mklabel gpt && /usr/sbin/parted -s /dev/vdb mkpart primary 2048 100% && /sbin/mkfs.ext4 /dev/vdb1
      - unless: ls /dev/vdb1

# http serving of mirrored packages
/etc/fstab:
  file.managed

/srv/mirror:
  file.directory:
    - user: wwwrun
    - group: users
    - mode: 755
    - makedirs: True
  mount.mounted:
    - device: /dev/vdb1
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: vdb1.device

web_server:
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
      - file: /srv/mirror
    - watch:
      - file: /etc/apache2/vhosts.d/package-mirror.conf

# NFS serving of mirrored packages

/etc/exports:
  file.append:
    - text: /srv/mirror *(ro,sync,no_root_squash)
    - require:
      - file: /srv/mirror

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
      - file: /etc/exports
      - service: nfs
    - watch:
      - file: /etc/exports

/srv/mirror/SUSE:
  file.symlink:
    - target: mirror/SuSE/build.suse.de/SUSE

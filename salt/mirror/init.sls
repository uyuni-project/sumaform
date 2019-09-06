include:
  - default

system_update:
  pkg.uptodate:
    - require:
      - sls: default

mozilla_certificates:
  pkg.installed:
    - name: ca-certificates-mozilla
    - require:
      - sls: default

minima:
  archive.extracted:
    - name: /usr/bin
    - source: https://github.com/moio/minima/releases/download/v0.8/minima-linux-amd64.tar.gz
    - source_hash: https://github.com/moio/minima/releases/download/v0.8/minima-linux-amd64.tar.gz.sha512
    - archive_format: tar
    - enforce_toplevel: false
    - keep: True
    - overwrite: True
    - require:
      - pkg: mozilla_certificates
      - pkg: system_update

minima_configuration:
  file.managed:
    - name: /root/minima.yaml
    - source: salt://mirror/minima.yaml
    - template: jinja

tar:
  pkg.installed:
    - require:
      - pkg: system_update

jdupes:
  archive.extracted:
    - name: /
    - source: https://github.com/jbruchon/jdupes/releases/download/v1.13.2/jdupes-1.13.2-linux64-static.tar.xz
    - source_hash: 078531eee63b434f3b8383367050a55d18fdd671c4d7800df82da9630a35ea62fc755e6337bd703d6526d3ae265f4d37b218aa1045629809498056a59bda3922
    - archive_format: tar
    - enforce_toplevel: false
    - options: --strip-components=1
    - keep: True
    - overwrite: True
    - require:
      - pkg: tar

# Ensure we have it: some images don't have it
cron:
  pkg.installed

parted:
  pkg.installed

scc_data_refresh_script:
  file.managed:
    - name: /root/refresh_scc_data.py
    - source: salt://mirror/refresh_scc_data.py
    - mode: 755

apt-mirror:
  pkg.installed:
    - require:
      - sls: default
  file.managed:
    - name: /etc/apt-mirror.list
    - source: salt://mirror/apt-mirror.list
    - template: jinja
    - require:
      - pkg: apt-mirror

mirror_script:
  file.managed:
    - name: /root/mirror.sh
    - source: salt://mirror/mirror.sh
    - mode: 755
    - template: jinja
  cron.present:
    - name: /root/mirror.sh
    - identifier: MIRROR
    - user: root
    - hour: 20
    - minute: 0
    - require:
      - pkg: cron
      - archive: minima
      - file: minima_configuration
      - file: mirror_script
  service.running:
    - name: cron
    - enable: True
    - watch:
      - file: /root/mirror.sh

mirror_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mkpart primary 2048 100% && sleep 1 && /sbin/mkfs.ext4 /dev/{{grains['data_disk_device']}}1
    - unless: ls /dev//{{grains['data_disk_device']}}1
    - require:
      - pkg: parted

# http serving of mirrored packages

mirror_directory:
  file.directory:
    - name: /srv/mirror
    - user: wwwrun
    - group: users
    - mode: 755
    - makedirs: True
    - require:
      - pkg: apache2
  mount.mounted:
    - name: /srv/mirror
    - device: /dev/{{grains['data_disk_device']}}1
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: mirror_partition

web_server:
  pkg.installed:
    - name: apache2
    - require:
      - sls: default
  file.managed:
    - name: /etc/apache2/vhosts.d/mirror.conf
    - source: salt://mirror/mirror.conf
    - require:
      - pkg: apache2
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache2
      - file: /etc/apache2/vhosts.d/mirror.conf
      - file: mirror_directory
    - watch:
      - file: /etc/apache2/vhosts.d/mirror.conf

# NFS serving of mirrored packages

exports_file:
  file.append:
    - name: /etc/exports
    - text: /srv/mirror *(ro,sync,no_root_squash,insecure)
    - require:
      - file: mirror_directory

rpcbind:
  service.running:
    - enable: True
    - require:
      - pkg: nfs_kernel_support

nfs_kernel_support:
  pkg.installed:
    - name: nfs-kernel-server
    - require:
      - sls: default

nfs:
  service.running:
    - enable: True
    - require:
      - service: rpcbind
      - pkg: nfs-kernel-server

nfs_server:
  service.running:
    - name: nfsserver
    - enable: True
    - require:
      - file: exports_file
      - service: nfs
    - watch:
      - file: exports_file

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
    - source: https://github.com/moio/minima/releases/download/v0.6/minima-linux-amd64.tar.gz
    - source_hash: https://github.com/moio/minima/releases/download/v0.6/minima-linux-amd64.tar.gz.sha512
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

parted:
  pkg.installed

scc_data_refresh_script:
  file.managed:
    - name: /root/refresh_scc_data.py
    - source: salt://mirror/refresh_scc_data.py
    - mode: 755

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

# HACK: direct serving of grafana archive
grafana_archive:
  file.managed:
    - name: /srv/mirror/grafana-4.2.0.linux-x64.tar.gz
    - source: https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.2.0.linux-x64.tar.gz
    - source_hash: sha512=8c100f5d61b8ebac2abb3894d3f37e926c6fd81eb3ab68fd966d2bc38d9ec2386fee15dd745f5efe7c0e52de06321f3e983fdab0185b3da3f28562b54c60994f
    - require:
      - file: mirror_directory

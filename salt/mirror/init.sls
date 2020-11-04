include:
  - default

mozilla_certificates:
  pkg.installed:
    - name: ca-certificates-mozilla
    - require:
      - sls: default

minima:
  archive.extracted:
    - name: /usr/bin
    - source: https://github.com/uyuni-project/minima/releases/download/v0.11/minima-linux-amd64.tar.gz
    - source_hash: https://github.com/uyuni-project/minima/releases/download/v0.11/minima-linux-amd64.tar.gz.sha512
    - archive_format: tar
    - enforce_toplevel: false
    - keep: True
    - overwrite: True
    - require:
      - pkg: mozilla_certificates
      - sls: default

mirror_configuration_dir:
  file.directory:
    - name: /root/.minima
    - user: root
    - group: root
    - mode: 750

minima_configuration:
  file.managed:
    - name: /root/.minima/minima.yaml
    - source: salt://mirror/{{ grains.get("minima_config_path") | default("minima.yaml", true) }}
    - template: jinja
    - require:
      - file: mirror_configuration_dir

mirrorsh_configuration:
  file.managed:
    - name: /root/.minima/mirror.sh.conf
    - source: salt://mirror/mirror.sh.conf
    - template: jinja
    - require:
      - file: mirror_configuration_dir

tar:
  pkg.installed:
    - require:
      - sls: default

jdupes:
  archive.extracted:
    - name: /
    - source: https://github.com/jbruchon/jdupes/releases/download/v1.18.1/jdupes_1.18.1-x86-64.pkg.tar.xz
    - source_hash: 7429fa365f63e8ce73c39cf42a3a5e26e8eb49246b3f58fae4ebb353478232a77cc17b4316cb7464bfc685f779bfb690559b24eb60fe61b0b97ea1b3a0ccba48
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
    - template: jinja
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
  cron.present:
{% if grains.get('use_mirror_images') %}
    - name: /root/mirror.sh --mirror-images --refresh-scc-data --apt-mirror --minima-sync=/root/.minima/minima.yaml --config=/root/.minima/mirror.sh.conf &> /var/log/full-mirror.log || cat /var/log/full-mirror.log
{% else %}
    - name: /root/mirror.sh --refresh-scc-data --apt-mirror --minima-sync=/root/.minima/minima.yaml --config=/root/.minima/mirror.sh.conf &> /var/log/full-mirror.log || cat /var/log/full-mirror.log
{% endif %}
    - identifier: MIRROR
    - user: root
    - hour: 20
    - minute: 0
    - require:
      - pkg: cron
      - archive: minima
      - file: minima_configuration
      - file: mirrorsh_configuration
      - file: mirror_script
  service.running:
    - name: cron
    - enable: True
    - watch:
      - file: /root/mirror.sh

{% set fstype = grains.get('data_disk_fstype') | default('ext4', true) %}
mirror_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mkpart primary 2048 100% && sleep 1 && /sbin/mkfs.{{fstype}} /dev/{{grains['data_disk_device']}}1
    - unless: ls /dev//{{grains['data_disk_device']}}1
    - require:
      - pkg: parted

# http serving of mirrored packages

mirror_directory:
  file.directory:
    - name: /srv/mirror
    - user: wwwrun
    - group: users
    - mode: 777
    - makedirs: True
    - require:
      - pkg: apache2
  mount.mounted:
    - name: /srv/mirror
    - device: /dev/{{grains['data_disk_device']}}1
    - fstype: {{fstype}}
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

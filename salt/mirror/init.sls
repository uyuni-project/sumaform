include:
  - default

# base programs and services

mozilla_certificates:
  pkg.installed:
    - name: ca-certificates-mozilla
    - require:
      - sls: default

cron:
  pkg.installed

cron_service:
  service.running:
    - name: cron
    - enable: True
    - require:
      - pkg: cron

parted:
  pkg.installed

tar:
  pkg.installed:
    - require:
      - sls: default

minima:
  archive.extracted:
    - name: /usr/local/bin/utils/
    - source: https://github.com/uyuni-project/minima/releases/download/v0.11/minima-linux-amd64.tar.gz
    - source_hash: https://github.com/uyuni-project/minima/releases/download/v0.11/minima-linux-amd64.tar.gz.sha512
    - archive_format: tar
    - enforce_toplevel: false
    - keep: True
    - overwrite: True
    - require:
      - pkg: mozilla_certificates
      - sls: default

apt-mirror:
  pkg.installed:
    - require:
      - sls: default

jdupes:
  archive.extracted:
    - name: /usr/local/bin/utils/
    - source: https://github.com/jbruchon/jdupes/releases/download/v1.18.1/jdupes_1.18.1-x86-64.pkg.tar.xz
    - source_hash: 7429fa365f63e8ce73c39cf42a3a5e26e8eb49246b3f58fae4ebb353478232a77cc17b4316cb7464bfc685f779bfb690559b24eb60fe61b0b97ea1b3a0ccba48
    - archive_format: tar
    - enforce_toplevel: false
    - options: --strip-components=3 --wildcards */jdupes
    - keep: True
    - overwrite: True
    - require:
      - pkg: tar

docker_images:
  file.managed:
    - name: /usr/local/bin/utils/docker_images
    - source: salt://mirror/utils/docker_images
    - mode: 755

adjust_external_repos:
  file.managed:
    - name: /usr/local/bin/utils/adjust_external_repos
    - source: salt://mirror/utils/adjust_external_repos
    - template: jinja
    - mode: 755

scc_data_refresh:
  file.managed:
    - name: /usr/local/bin/utils/refresh_scc_data.py
    - source: salt://mirror/utils/refresh_scc_data.py
    - template: jinja
    - mode: 755


# mirroring scripts

minima_configuration:
  file.managed:
    - name: /etc/minima.yaml
    - source: salt://mirror/etc/minima.yaml
    - template: jinja

minima_script:
  file.managed:
    - name: /usr/local/bin/minima.sh
    - source: salt://mirror/cron_scripts/minima.sh
    - mode: 755
    - require:
      - pkg: cron
      - archive: minima
      - file: minima_configuration

minima_symlink:
  file.symlink:
    - name: /etc/cron.daily/minima.sh
    - target: /usr/local/bin/minima.sh
    - require:
      - file: minima_script

apt-mirror_configuration:
  file.managed:
    - name: /etc/apt-mirror.list
    - source: salt://mirror/etc/apt-mirror.list
    - template: jinja
    - require:
      - pkg: apt-mirror

apt-mirror_script:
  file.managed:
    - name: /usr/local/bin/apt-mirror.sh
    - source: salt://mirror/cron_scripts/apt-mirror.sh
    - mode: 755
    - require:
      - pkg: cron
      - pkg: apt-mirror
      - file: apt-mirror_configuration

apt-mirror_symlink:
  file.symlink:
    - name: /etc/cron.daily/apt-mirror.sh
    - target: /usr/local/bin/apt-mirror.sh
    - require:
      - file: apt-mirror_script

mirror-images_configuration:
  file.managed:
    - name: /etc/mirror-images.conf
    - source: salt://mirror/etc/mirror-images.conf

mirror-images_script:
  file.managed:
    - name: /usr/local/bin/mirror-images.sh
    - source: salt://mirror/cron_scripts/mirror-images.sh
    - mode: 755
    - require:
      - pkg: cron
      - file: mirror-images_configuration

mirror-images_symlink:
  file.symlink:
    - name: /etc/cron.daily/mirror-images.sh
    - target: /usr/local/bin/mirror-images.sh
    - require:
      - file: mirror-images_script

docker-images_configuration:
  file.managed:
    - name: /etc/docker-images.conf
    - source: salt://mirror/etc/docker-images.conf
    - template: jinja

docker-images_script:
  file.managed:
    - name: /usr/local/bin/docker-images.sh
    - source: salt://mirror/cron_scripts/docker-images.sh
    - mode: 755
    - require:
      - pkg: cron
      - file: docker-images_configuration

# no symlinck by default for docker-images.sh
# (docker is not installed by default)

scc-data_configuration:
  file.managed:
    - name: /etc/scc-data.conf
    - source: salt://mirror/etc/scc-data.conf
    - template: jinja

scc-data_script:
  file.managed:
    - name: /usr/local/bin/scc-data.sh
    - source: salt://mirror/cron_scripts/scc-data.sh
    - mode: 755
    - require:
      - pkg: cron
      - file: scc-data_configuration

scc-data_symlink:
  file.symlink:
    - name: /etc/cron.daily/scc-data.sh
    - target: /usr/local/bin/scc-data.sh
    - require:
      - file: scc-data_script


# partitioning

{% set fstype = grains.get('data_disk_fstype') | default('ext4', true) %}
mirror_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mkpart primary 2048 100% && sleep 1 && /sbin/mkfs.{{fstype}} /dev/{{grains['data_disk_device']}}1
    - unless: ls /dev//{{grains['data_disk_device']}}1
    - require:
      - pkg: parted


# HTTP serving of mirrored packages

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
    - source: salt://mirror/etc/mirror.conf
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

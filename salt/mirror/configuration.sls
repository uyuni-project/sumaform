# base programs and services

mozilla_certificates:
  pkg.installed:
    - name: ca-certificates-mozilla
    - require:
      - sls: default

parted:
  pkg.installed

tar:
  pkg.installed:
    - require:
      - sls: default

minima:
  archive.extracted:
    - name: /usr/local/bin/utils/
    - source: https://github.com/uyuni-project/minima/releases/download/v0.25/minima_0.25_linux_amd64.tar.gz
    - source_hash: https://github.com/uyuni-project/minima/releases/download/v0.25/minima_0.25_checksums.txt
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
    - source: https://codeberg.org/jbruchon/jdupes/releases/download/v1.27.3/jdupes-1.27.3-linux-x86_64.pkg.tar.xz
    - source_hash: d59159e3ceb263dbff465a7f2115ab9730c90a651b2aba62f95da957ec26891a0f5e83380f5e7629adf9d4b5ab8e64a54698b6f8c023eb0c5f8cf048ada29b07
    - archive_format: tar
    - enforce_toplevel: false
    - options: --strip-components=1 --wildcards */jdupes
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
    - source: salt://{{ grains.get("customize_minima_file") | default("mirror/etc/minima.yaml", true) }}
    - template: jinja

minima_script:
  file.managed:
    - name: /usr/local/bin/minima.sh
    - source: salt://mirror/cron_scripts/minima.sh
    - mode: 755
    - require:
      - archive: minima
      - file: minima_configuration

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
      - pkg: apt-mirror
      - file: apt-mirror_configuration

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
      - file: mirror-images_configuration

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
      - file: docker-images_configuration

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
      - file: scc-data_configuration


# partitioning

{% set fstype = grains.get('data_disk_fstype') | default('ext4', true) %}
{% if grains['data_disk_device'] == "nvme1n1" %}
{% set partition_name = '/dev/' + grains['data_disk_device'] + 'p1' %}
{% else %}
{% set partition_name = '/dev/' + grains['data_disk_device'] + '1' %}
{% endif %}

mirror_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mkpart primary 2048 100% && sleep 1 && /sbin/mkfs.{{fstype}} {{partition_name}}
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
    - device: {{partition_name}}
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

nfs_ganesha:
  pkg.installed:
    - names: [nfs-ganesha, nfs-ganesha-vfs]
    - require:
      - sls: default
  file.append:
    - name: /etc/ganesha/ganesha.conf
    - text: |
        EXPORT
        {
                Export_Id = 1;
                Path = /srv/mirror;
                Pseudo = /srv/mirror;
                Access_Type = RO;
                SecType = None;
                Squash = None;
                FSAL
                {
                        Name = VFS;
                }
        }
    - require:
      - file: mirror_directory
  service.running:
    - name: nfs-ganesha
    - enable: True

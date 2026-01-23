include:
  - default

parted:
  pkg.installed

{% if grains.get('repository_disk_size') > 0 %}
{% if grains.get('repository_disk_use_cloud_setup') %}

susemanager-cloud-setup-server:
  pkg.installed

spacewalk_directory:
  cmd.run:
{% if grains.get('database_disk_size') > 0 %}
    - name: suma-storage /dev/{{grains['data_disk_device']}} /dev/{{grains['second_data_disk_device']}}
{% else %}
    - name: suma-storage /dev/{{grains['data_disk_device']}}
{% endif %}
    - require:
      - pkg: susemanager-cloud-setup-server

{% else %}

{% set fstype = grains.get('data_disk_fstype') | default('ext4', true) %}
{% if grains['data_disk_device'] == "nvme0n1" %}
{% set partition_name = '/dev/' + grains['data_disk_device'] + 'p1' %}
{% else %}
{% set partition_name = '/dev/' + grains['data_disk_device'] + '1' %}
{% endif %}

spacewalk_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mkpart primary 0% 100% && sleep 1 && /sbin/mkfs.{{fstype}} {{partition_name}}
    - unless: ls {{partition_name}}
    - require:
      - pkg: parted

www:
  group.present:
    - system: True

wwwrun:
  group.present:
    - system: True
  user.present:
    - fullname: WWW daemon apache
    - shell: /usr/sbin/nologin
    - home: /var/lib/wwwrun
    - groups:
      - wwwrun
      - www

spacewalk_directory:
  file.directory:
    - name: /var/spacewalk
    - makedirs: True
    - user: wwwrun
    - group: www
    - dir_mode: 775
    - recurse:
      - user
      - group
      - mode
  mount.mounted:
    - name: /var/spacewalk
    - device: {{partition_name}}
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: spacewalk_partition

{% endif %} # grains.get('repository_disk_use_cloud_setup')
{% endif %} # grains.get('repository_disk_size')

{% if grains.get('database_disk_size') > 0 %}
{% if not grains.get('repository_disk_use_cloud_setup') %}

{% set fstype = grains.get('second_data_disk_fstype') | default('ext4', true) %}
{% if grains['second_data_disk_device'] == "nvme2n1" %}
{% set partition_name = '/dev/' + grains['second_data_disk_device'] + 'p1' %}
{% else %}
{% set partition_name = '/dev/' + grains['second_data_disk_device'] + '1' %}
{% endif %}


pgsql_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['second_data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev/{{grains['second_data_disk_device']}} mkpart primary 0% 100% && sleep 1 && /sbin/mkfs.{{fstype}} {{partition_name}}
    - unless: ls {{partition_name}}
    - require:
        - pkg: parted

postgres:
  mount.mounted:
    - name: /var/lib/pgsql
    - device: {{partition_name}}
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
        - defaults
    - require:
        - cmd: pgsql_partition
  group.present:
    - system: True
  user.present:
    - fullname: PostgreSQL Server
    - shell: /bin/bash
    - home: /var/lib/pgsql
    - gid: postgres
    - system: True

pgsql_directory:
  file.directory:
    - name: /var/lib/pgsql
    - makedirs: True
    - user: postgres
    - group: postgres
    - dir_mode: 750
    - recurse:
      - user
      - group
      - mode

{% endif %} # grains.get('repository_disk_use_cloud_setup')
{% endif %} # grains.get('database_disk_size')

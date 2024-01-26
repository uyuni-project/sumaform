include:
  - default

parted:
  pkg.installed

{% if grains.get('repository_disk_size') > 0 %}

{% set fstype = grains.get('data_disk_fstype') | default('ext4', true) %}
{% if grains['data_disk_device'] == "nvme1n1" %}
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

spacewalk_move_data:
  cmd.run:
    - name: 'mv /var/lib/containers/storage/volumes/var-spacewalk /var/spacewalk/'
    - require:
      - file: spacewalk_directory

spacewalk_symlink:
  file.symlink:
    - name: /var/lib/containers/storage/volumes/var-spacewalk/
    - target: /var/spacewalk
    - force: True
    - require:
      - cmd: spacewalk_move_data

{% endif %}

{% if grains.get('database_disk_size') > 0 %}

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
  group.present:
    - gid: 464
    - system: True
  user.present:
    - fullname: PostgreSQL Server
    - shell: /bin/bash
    - home: /var/lib/pgsql
    - uid: 464
    - gid: 464
    - groups:
      - postgres

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

{% endif %}

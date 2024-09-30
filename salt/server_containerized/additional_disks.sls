include:
  - default

parted:
  pkg.installed

{% set repository_disk_size = grains.get('repository_disk_size') | int %}
{% if repository_disk_size > 0 %}

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
    - name: /srv/spacewalk_storage
    - makedirs: True
  mount.mounted:
    - name: /srv/spacewalk_storage
    - device: {{partition_name}}
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: spacewalk_partition

spacewalk_data_directory:
  file.directory:
    - name: /srv/spacewalk_storage/var-spacewalk
    - makedirs: True
    - require:
      - mount: spacewalk_directory

spacewalk_symlink:
  file.symlink:
    - name: /var/lib/containers/storage/volumes/var-spacewalk
    - target: /srv/spacewalk_storage/var-spacewalk/
    - makedirs : True
    - force: True
    - require:
      - file: spacewalk_data_directory

{% endif %}

{% set database_disk_size = grains.get('database_disk_size') | int %}
{% if database_disk_size > 0 %}

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

pgsql_directory:
  file.directory:
    - name: /srv/pgsql_storage
    - makedirs: True
  mount.mounted:
    - name: /srv/pgsql_storage
    - device: {{partition_name}}
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: pgsql_partition

pgsql_data_directory:
  file.directory:
    - name: /srv/pgsql_storage/var-pgsql
    - makedirs: True
    - require:
      - mount: pgsql_directory


pgsql_symlink:
  file.symlink:
    - name: /var/lib/containers/storage/volumes/var-pgsql
    - target: /srv/pgsql_storage/var-pgsql/
    - makedirs: True
    - force: True
    - require:
      - file: pgsql_data_directory

{% endif %}

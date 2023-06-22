include:
  - default

{% if grains.get('repository_disk_size') > 0 %}

parted:
  pkg.installed

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

{% endif %}

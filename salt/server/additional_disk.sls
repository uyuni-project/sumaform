include:
  - default

{% if grains.get('repository_disk_size') > 0 %}

parted:
  pkg.installed

spacewalk_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mkpart primary 0% 100% && sleep 1 && /sbin/mkfs.ext4 /dev/{{grains['data_disk_device']}}1
    - unless: ls /dev/{{grains['data_disk_device']}}1
    - require:
      - pkg: parted

spacewalk_directory:
  file.directory:
    - name: /var/spacewalk
    - makedirs: True
  mount.mounted:
    - name: /var/spacewalk
    - device: /dev/{{grains['data_disk_device']}}1
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: spacewalk_partition

{% endif %}

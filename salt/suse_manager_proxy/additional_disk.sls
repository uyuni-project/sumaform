include:
  - default

{% if grains.get('repository_disk_size') > 0 %}

parted:
  pkg.installed

spacewalk_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/vdb mklabel gpt && /usr/sbin/parted -s /dev/vdb mkpart primary 0% 100% && sleep 1 && /sbin/mkfs.ext4 /dev/vdb1
    - unless: ls /dev/vdb1
    - require:
      - pkg: parted

spacewalk_directory:
  file.directory:
    - name: /var/spacewalk
    - makedirs: True
  mount.mounted:
    - name: /var/spacewalk
    - device: /dev/vdb1
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: spacewalk_partition

{% endif %}

{% set export_path      = grains.get('export_path')      | default('/srv/nfs', true) %}
{% set allowed_cidr     = grains.get('allowed_cidr')     | default('0.0.0.0/0', true) %}
{% set export_options   = grains.get('export_options')   | default('rw,sync,no_subtree_check,no_root_squash', true) %}
{% set data_disk_size   = grains.get('data_disk_size')   | int %}
{% set data_disk_device = grains.get('data_disk_device') | default('vdb', true) %}
{% set data_disk        = data_disk_device if data_disk_device.startswith('/dev/') else '/dev/' ~ data_disk_device %}

include:
  - repos

install_nfs_server:
  pkg.installed:
    - name: nfs-kernel-server
    - require:
      - sls: repos

{% if data_disk_size > 0 %}

format_nfs_data_disk:
  blockdev.formatted:
    - name: {{ data_disk }}
    - fs_type: xfs

mount_nfs_data_disk:
  mount.mounted:
    - name: {{ export_path }}
    - device: {{ data_disk }}
    - fstype: xfs
    - mkmnt: True
    - persist: True
    - require:
      - blockdev: format_nfs_data_disk

{% else %}

export_directory:
  file.directory:
    - name: {{ export_path }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% endif %}

configure_exports:
  file.managed:
    - name: /etc/exports
    - contents: |
        {{ export_path }} {{ allowed_cidr }}({{ export_options }})
    - user: root
    - group: root
    - mode: 644
    - require:
{% if data_disk_size > 0 %}
      - mount: mount_nfs_data_disk
{% else %}
      - file: export_directory
{% endif %}

apply_exports:
  cmd.run:
    - name: exportfs -ra
    - require:
      - pkg: install_nfs_server
    - onchanges:
      - file: configure_exports

nfs_server_service:
  service.running:
    - name: nfs-server
    - enable: True
    - require:
      - pkg: install_nfs_server
      - file: configure_exports
    - watch:
      - file: configure_exports

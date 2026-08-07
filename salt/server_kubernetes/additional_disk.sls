{% set local_path = grains.get('local_path_provisioner_path') | default('/opt/local-path-provisioner', true) %}
{% set var_pgsql_host_path = grains.get('kubernetes_var_pgsql_host_path') | default(local_path ~ '/var-pgsql18', true) %}

# xfs, like the root filesystem. The var-pgsql18 volume is mounted straight on
# the PostgreSQL data directory, and initdb refuses to run in a directory that
# holds the lost+found an ext filesystem creates.

{% if grains.get('repository_disk_size') | int > 0 %}

local_path_provisioner_disk:
  blockdev.formatted:
    - name: /dev/{{ grains['data_disk_device'] }}
    - fs_type: xfs
  mount.mounted:
    - name: {{ local_path }}
    - device: /dev/{{ grains['data_disk_device'] }}
    - fstype: xfs
    - mkmnt: True
    - persist: True
    - require:
      - blockdev: local_path_provisioner_disk

{% endif %}

{% if grains.get('database_disk_size') | int > 0 %}

var_pgsql_disk:
  blockdev.formatted:
    - name: /dev/{{ grains['second_data_disk_device'] }}
    - fs_type: xfs
  mount.mounted:
    - name: {{ var_pgsql_host_path }}
    - device: /dev/{{ grains['second_data_disk_device'] }}
    - fstype: xfs
    - mkmnt: True
    - persist: True
    - require:
      - blockdev: var_pgsql_disk
{% if grains.get('repository_disk_size') | int > 0 %}
      - mount: local_path_provisioner_disk
{% endif %}

{% endif %}

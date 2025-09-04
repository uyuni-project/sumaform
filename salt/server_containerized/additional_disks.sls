include:
  - default

{% set repository_disk_size = grains.get('repository_disk_size') | int %}
{% set database_disk_size = grains.get('database_disk_size') | int %}

# note that having only a DB disk defined results in the tool using it to store all data.
{% if repository_disk_size > 0 or database_disk_size > 0 %}

{% set repository_device_name = '/dev/' + grains.get('data_disk_device', '') if repository_disk_size > 0 else '' %}
{% set db_device_name = '/dev/' + grains.get('second_data_disk_device', '') if database_disk_size > 0 else '' %}

mgr_storage_dir:
  file.directory:
    - name: /var/lib/containers/storage
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True

mgr_volumes_dir:
  file.directory:
    - name: /var/lib/containers/storage/volumes
    - user: root
    - group: root
    - dir_mode: 700
    - require:
      - file: mgr_storage_dir

mgr_storage:
  cmd.run: 
    - name: mgr-storage-server {{repository_device_name}} {{db_device_name}}
    - require:
      - file: mgr_volumes_dir

{% endif %}

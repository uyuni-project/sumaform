include:
  - default

{% set repository_disk_size = grains.get('repository_disk_size') | int %}
{% set database_disk_size = grains.get('database_disk_size') | int %}

{% set repository_device_name = '/dev/' + grains.get('data_disk_device', '') if repository_disk_size > 0 else '' %}
{% set db_device_name = '/dev/' + grains.get('second_data_disk_device', '') if database_disk_size > 0 else '' %}

mgr_storage_:
  cmd.run: 
    - name: mgr-storage-server {{repository_device_name}} {{db_device_name}}

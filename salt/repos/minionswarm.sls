{% if grains.get('role') == 'minionswarm' %}

suse_manager_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SUSE-Manager-Server/3.2/x86_64/product/
    - priority: 97

suse_manager_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SUSE-Manager-Server/3.2/x86_64/update/
    - priority: 97

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

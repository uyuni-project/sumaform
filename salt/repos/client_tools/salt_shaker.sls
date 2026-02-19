{% if not grains.get('product_version') and 'salt_testenv' in grains.get('roles') %}

{% if grains['osfullname'] == 'SLES' and '15' in grains['osrelease'] %}
shaker_tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15/{{ grains.get("cpuarch") }}/product/
    - refresh: True

shaker_tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15/{{ grains.get("cpuarch") }}/update/
    - refresh: True
{% endif %}

{% endif %}

{% if 'server' in grains.get('roles') %}

{% if 'uyuni-released' in grains['product_version'] %}
server_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable/images/repo/Uyuni-Server-POOL-{{ grains.get("cpuarch") }}-Media1/
    - refresh: True
    - priority: 97
{% endif %}

{% if 'uyuni-master' in grains.get('product_version') %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master/images/repo/Uyuni-Server-POOL-{{ grains.get("cpuarch") }}-Media1/
    - refresh: True
    - priority: 96

testing_overlay_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master/images/repo/Testing-Overlay-POOL-{{ grains.get("cpuarch") }}-Media1/
    - refresh: True
    - priority: 96

{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

server_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable/images/repo/Uyuni-Server-POOL-x86_64-Media1/
    - refresh: True
    - priority: 97

{% if 'uyuni-master' == grains['product_version'] %}

server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master/images/repo/Uyuni-Server-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96

testing_overlay_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master/images/repo/Testing-Overlay-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

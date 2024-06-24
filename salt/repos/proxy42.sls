{% if 'proxy' in grains.get('roles') %}

{% if '4.2' in grains['product_version'] and not grains.get('proxy_registration_code') %}
proxy_product_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Product-SUSE-Manager-Proxy/4.2/x86_64/product/
    - refresh: True

proxy_product_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SUSE-Manager-Proxy/4.2/x86_64/update/
    - refresh: True

{% if 'beta' in grains['product_version'] %}
proxy_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/SLE-15-SP3:/Update:/Products:/Manager42/images/repo/SLE-Module-SUSE-Manager-Proxy-4.2-POOL-x86_64-Media1/
    - refresh: True
{% else %}
proxy_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-SUSE-Manager-Proxy/4.2/x86_64/product/
    - refresh: True

proxy_module_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-SUSE-Manager-Proxy/4.2/x86_64/update/
    - refresh: True
{% endif %}

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP3/x86_64/product/
    - refresh: True

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP3/x86_64/update/
    - refresh: True

{% endif %}

{% if '4.2-nightly' in grains['product_version'] %}
proxy_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.2/images/repo/SLE-Module-SUSE-Manager-Proxy-4.2-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96

proxy_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.2:/ToSLE/SLE_15_SP3/
    - refresh: True
    - priority: 96

testing_overlay_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.2/images/repo/SLE-Module-SUSE-Manager-Testing-Overlay-4.2-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96
{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

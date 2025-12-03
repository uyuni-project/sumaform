{% if 'server' in grains.get('roles') %}

{% if '4.3' in grains['product_version'] and not grains.get('server_registration_code') %}
server_product_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Product-SUSE-Manager-Server/4.3/{{ grains.get("cpuarch") }}/product/
    - refresh: True

server_product_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Product-SUSE-Manager-Server/4.3/{{ grains.get("cpuarch") }}/update/
    - refresh: True

server_product_LTS_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Product-SUSE-Manager-Server/4.3-LTS/{{ grains.get("cpuarch") }}/update/
    - refresh: True

server_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Module-SUSE-Manager-Server/4.3/{{ grains.get("cpuarch") }}/product/
    - refresh: True

server_module_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Module-SUSE-Manager-Server/4.3/{{ grains.get("cpuarch") }}/update/
    - refresh: True

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP4/{{ grains.get("cpuarch") }}/product/
    - refresh: True

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP4/{{ grains.get("cpuarch") }}/update/
    - refresh: True

module_web_scripting_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Module-Web-Scripting/15-SP4/{{ grains.get("cpuarch") }}/product/
    - refresh: True

module_web_scripting_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Module-Web-Scripting/15-SP4/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% endif %}

{% if '4.3-nightly' in grains['product_version'] or '4.3-pr' in grains['product_version'] or '4.3-VM-nightly' in grains['product_version'] %}

server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3/images/repo/SLE-Module-SUSE-Manager-Server-4.3-POOL-{{ grains.get("cpuarch") }}-Media1/
    - refresh: True
    - priority: 96

server_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/ToSLE/SLE_15_SP4/
    - refresh: True
    - priority: 96

testing_overlay_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3/images/repo/SLE-Module-SUSE-Manager-Testing-Overlay-4.3-POOL-{{ grains.get("cpuarch") }}-Media1/
    - refresh: True
    - priority: 96
{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

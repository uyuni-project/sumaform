{% if 'proxy' in grains.get('roles') %}

{% if '4.1' in grains['product_version'] and not grains.get('proxy_registration_code')%}
proxy_product_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Product-SUSE-Manager-Proxy/4.1/x86_64/product/
    - refresh: True

proxy_product_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SUSE-Manager-Proxy/4.1/x86_64/update/
    - refresh: True

proxy_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-SUSE-Manager-Proxy/4.1/x86_64/product/
    - refresh: True

proxy_module_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-SUSE-Manager-Proxy/4.1/x86_64/update/
    - refresh: True

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP2/x86_64/product/
    - refresh: True

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP2/x86_64/update/
    - refresh: True
{% endif %}

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

{% if '4.3' in grains['product_version'] and not grains.get('proxy_registration_code') %}
proxy_product_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Product-SUSE-Manager-Proxy/4.3/x86_64/product/
    - refresh: True

proxy_product_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SUSE-Manager-Proxy/4.3/x86_64/update/
    - refresh: True

{% if 'beta' in grains['product_version'] %}
proxy_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/SLE-15-SP4:/Update:/Products:/Manager43/images/repo/SLE-Module-SUSE-Manager-Proxy-4.3-POOL-x86_64-Media1/
    - refresh: True
{% else %}
proxy_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-SUSE-Manager-Proxy/4.3/x86_64/product/
    - refresh: True

proxy_module_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-SUSE-Manager-Proxy/4.3/x86_64/update/
    - refresh: True

{% endif %}

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP4/x86_64/product/
    - refresh: True

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP4/x86_64/update/
    - refresh: True

{% endif %}

{% if 'uyuni-released' in grains['product_version'] %}
proxy_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable/images/repo/Uyuni-Proxy-POOL-x86_64-Media1/
    - refresh: True
    - priority: 97
{% endif %}

{% if 'head' in grains.get('product_version') or 'uyuni-master' in grains.get('product_version') %}
{% if grains['osfullname'] == 'Leap' %}
proxy_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master/images/repo/Uyuni-Proxy-POOL-x86_64-Media1/
    - refresh: True
    - priority: 97
{% else %}
proxy_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/SLE-Module-SUSE-Manager-Proxy-4.3-POOL-x86_64-Media1/
    - refresh: True
    - priority: 97
{% endif %}

{% if grains['osfullname'] != 'Leap' %}
server_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/ToSLE/SLE_15_SP4/
    - refresh: True
    - priority: 96
{% endif %}

{% if grains['osfullname'] == 'Leap' %}
testing_overlay_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master/images/repo/Testing-Overlay-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96
{% else %}
testing_overlay_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/SLE-Module-SUSE-Manager-Testing-Overlay-4.3-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96
{% endif %}

{% if grains['osfullname'] != 'Leap' %}
module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP4/x86_64/product/
    - refresh: True

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP4/x86_64/update/
    - refresh: True

{% endif %}
{% endif %}

{% if '4.1-nightly' in grains['product_version'] %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.1/images/repo/SLE-Module-SUSE-Manager-Proxy-4.1-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96

server_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.1:/ToSLE/SLE_15_SP2/
    - refresh: True
    - priority: 96

testing_overlay_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.1/images/repo/SLE-Module-SUSE-Manager-Testing-Overlay-4.1-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96
{% endif %}

{% if '4.2-nightly' in grains['product_version'] %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.2/images/repo/SLE-Module-SUSE-Manager-Proxy-4.2-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96

server_devel_releasenotes_repo:
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

{% if '4.3-nightly' in grains['product_version'] %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3/images/repo/SLE-Module-SUSE-Manager-Proxy-4.3-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96

server_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/ToSLE/SLE_15_SP4/
    - refresh: True
    - priority: 96

testing_overlay_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3/images/repo/SLE-Module-SUSE-Manager-Testing-Overlay-4.3-POOL-x86_64-Media1/
    - refresh: True
    - priority: 96
{% endif %}

# repositories needed for containerized proxy
{% if grains.get('proxy_containerized') | default(false, true) or grains.get('testsuite') | default(false, true)%}

# temporary hack since for now we only want to add this on head and uyuni
{% if 'head' in grains.get('product_version') or 'uyuni-master' in grains.get('product_version') %}

{% if grains['osfullname'] == 'Leap' %}
{% set ca_path = 'openSUSE_Leap_' + grains['osrelease'] %}
{% endif %}

{% if grains['osfullname'] != 'Leap' %}
{% if grains['osrelease'] == '15.1' %}
{% set ca_path = 'SLE_15_SP1' %}
{% elif grains['osrelease'] == '15.2' %}
{% set ca_path = 'SLE_15_SP2' %}
{% elif grains['osrelease'] == '15.3' %}
{% set ca_path = 'SLE_15_SP3' %}
{% elif grains['osrelease'] == '15.4' %}
{% set ca_path = 'SLE_15_SP4' %}
{% endif %}
{% endif %}

ca_certificates_suse_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/CA/{{ca_path}}/
    - refresh: True

{% if 'head' in grains.get('product_version') %}
containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/15-SP4/x86_64/product/
    - refresh: True

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/15-SP4/x86_64/update/
    - refresh: True
{% endif %}

{% endif %}
{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

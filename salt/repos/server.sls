{% if 'server' in grains.get('roles') %}

{% if '3.2' in grains['product_version'] %}
server_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SUSE-Manager-Server/3.2/x86_64/product
    - priority: 97

server_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SUSE-Manager-Server/3.2/x86_64/update/
    - priority: 97
{% endif %}

{% if '4.0' in grains['product_version'] %}
server_product_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Product-SUSE-Manager-Server/4.0/x86_64/product/

server_product_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SUSE-Manager-Server/4.0/x86_64/update/

server_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-SUSE-Manager-Server/4.0/x86_64/product/

server_module_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-SUSE-Manager-Server/4.0/x86_64/update/

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP1/x86_64/product/

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP1/x86_64/update/

module_web_scripting_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Web-Scripting/15-SP1/x86_64/product/

module_web_scripting_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Web-Scripting/15-SP1/x86_64/update/

module_python2_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Python2/15-SP1/x86_64/product/

module_python2_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Python2/15-SP1/x86_64/update/
{% endif %}

{% if '4.1' in grains['product_version'] and grains['server_registry_code'] == 'null' %}
server_product_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Product-SUSE-Manager-Server/4.1/x86_64/product/

server_product_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SUSE-Manager-Server/4.1/x86_64/update/

server_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-SUSE-Manager-Server/4.1/x86_64/product/

server_module_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-SUSE-Manager-Server/4.1/x86_64/update/

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP2/x86_64/product/

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP2/x86_64/update/

module_web_scripting_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Web-Scripting/15-SP2/x86_64/product/

module_web_scripting_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Web-Scripting/15-SP2/x86_64/update/

module_python2_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Python2/15-SP2/x86_64/product/

module_python2_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Python2/15-SP2/x86_64/update/
{% endif %}

{% if '4.2' in grains['product_version'] %}
server_product_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Product-SUSE-Manager-Server/4.2/x86_64/product/

server_product_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SUSE-Manager-Server/4.2/x86_64/update/

{% if 'beta' in grains['product_version'] %}
server_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/SLE-15-SP3:/Update:/Products:/Manager42/images/repo/SLE-Module-SUSE-Manager-Server-4.2-POOL-x86_64-Media1/
{% else %}
server_module_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-SUSE-Manager-Server/4.2/x86_64/product/

server_module_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-SUSE-Manager-Server/4.2/x86_64/update/
{% endif %}

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP3/x86_64/product/

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP3/x86_64/update/

module_web_scripting_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Web-Scripting/15-SP3/x86_64/product/

module_web_scripting_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Web-Scripting/15-SP3/x86_64/update/

module_python2_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Python2/15-SP3/x86_64/product/

module_python2_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Python2/15-SP3/x86_64/update/

{% endif %}


{% if 'uyuni-released' in grains['product_version'] %}
server_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable/images/repo/Uyuni-Server-POOL-x86_64-Media1/
    - priority: 97
{% endif %}

{% if 'head' in grains.get('product_version') or 'uyuni-master' in grains.get('product_version') %}
{% if grains['osfullname'] == 'Leap' %}
server_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master/images/repo/Uyuni-Server-POOL-x86_64-Media1/
    - priority: 97
{% else %}
server_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/SLE-Module-SUSE-Manager-Server-4.2-POOL-x86_64-Media1/
    - priority: 97
{% endif %}

{% if grains['osfullname'] != 'Leap' %}
server_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/ToSLE/SLE_15_SP3/
    - priority: 96
{% endif %}

{% if grains['osfullname'] == 'Leap' %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master/openSUSE_Leap_15.3/
    - priority: 96
{% else %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/SLE_15_SP3/
    - priority: 96
{% endif %}

{% if grains['osfullname'] != 'Leap' %}
# Moving target, only until SLE15SP3 GA is ready
module_server_applications_movingtarget_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/SLE-15-SP3:/GA:/TEST/images/repo/SLE-15-SP3-Module-Server-Applications-POOL-x86_64-Media1/

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/15-SP3/x86_64/product/

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/15-SP3/x86_64/update/

# Moving target, only until SLE15SP3 GA is ready
module_web_scripting_movingtarget_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/SLE-15-SP3:/GA:/TEST/images/repo/SLE-15-SP3-Module-Web-Scripting-POOL-x86_64-Media1/

module_web_scripting_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Web-Scripting/15-SP3/x86_64/product/

module_web_scripting_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Web-Scripting/15-SP3/x86_64/update/

# Moving target, only until SLE15SP3 GA is ready
module_python2_movingtarget_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/SLE-15-SP3:/GA:/TEST/images/repo/SLE-15-SP3-Module-Python2-POOL-x86_64-Media1/

module_python2_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Python2/15-SP3/x86_64/product/

module_python2_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Python2/15-SP3/x86_64/update/
{% endif %}
{% endif %}

{% if '3.2-nightly' in grains['product_version'] %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/3.2/SLE_12_SP3/
    - priority: 96
{% endif %}

{% if '4.0-nightly' in grains['product_version'] %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.0/SLE_15_SP1/
    - priority: 96

server_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.0:/ToSLE/SLE_15_SP1/
    - priority: 96
{% endif %}

{% if '4.1-nightly' in grains['product_version'] %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.1/SLE_15_SP2/
    - priority: 96

server_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.1:/ToSLE/SLE_15_SP2/
    - priority: 96
{% endif %}

{% if '4.2-nightly' in grains['product_version'] %}
server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.2/SLE_15_SP3/
    - priority: 96

server_devel_releasenotes_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.2:/ToSLE/SLE_15_SP3/
    - priority: 96
{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

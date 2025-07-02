{% if 'proxy_containerized' in grains.get('roles') %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SL-Micro' %}

{% if '5.1-released' in grains['product_version'] %}
# Commented out because we already add this repo in cloud-init:
# container_utils_pool_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/Multi-Linux-Manager-Proxy/5.1/x86_64/product
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/Multi-Linux-Manager-Proxy/5.1/x86_64/product/repodata/repomd.xml.key
# container_utils_updates_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/Multi-Linux-Manager-Proxy/5.1/x86_64/update
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/Multi-Linux-Manager-Proxy/5.1/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% if '5.1-nightly' in grains['product_version'] %}
# Commented out because we already add this repo in cloud-init:
# manager51_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/Devel:/Galaxy:/Manager:/5.1/images/repo/Multi-Linux-Manager-Proxy-5.1-x86_64
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/Devel:/Galaxy:/Manager:/5.1/images/repo/Multi-Linux-Manager-Proxy-5.1-x86_64/repodata/repomd.xml.key
{% endif %}

{% elif grains['osfullname'] == 'SLES' %}
ca_suse_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/SUSE:/CA/SLE_15_SP7
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/SUSE:/CA/SLE_15_SP7/repodata/repomd.xml.key

containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Module-Containers/15-SP7/x86_64/product
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Module-Containers/15-SP7/x86_64/product/repodata/repomd.xml.key

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/15-SP7/x86_64/update
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/15-SP7/x86_64/update/repodata/repomd.xml.key

{% if '5.1-released' in grains['product_version'] %}
container_utils_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/Multi-Linux-Manager-Proxy-SLE/5.1/x86_64/product
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/Multi-Linux-Manager-Proxy-SLE/5.1/x86_64/product/repodata/repomd.xml.key
container_utils_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/Multi-Linux-Manager-Proxy-SLE/5.1/x86_64/update
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/Multi-Linux-Manager-Proxy-SLE/5.1/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% if '5.1-nightly' in grains['product_version'] %}
manager51_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/Devel:/Galaxy:/Manager:/5.1/images-SP7/repo/SUSE-Multi-Linux-Manager-Proxy-SLE-5.1-POOL-x86_64-Media1
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/Devel:/Galaxy:/Manager:/5.1/images-SP7/repo/SUSE-Multi-Linux-Manager-Proxy-SLE-5.1-POOL-x86_64-Media1/repodata/repomd.xml.key
{% endif %}

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

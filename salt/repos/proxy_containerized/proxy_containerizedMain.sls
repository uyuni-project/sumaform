{% if 'proxy_containerized' in grains.get('roles') %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SLES' %}

{% if 'head-staging' in grains.get('product_version') %}
proxy_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE:/SLE-15-SP7:/Update:/Products:/MultiLinuxManager52:/ToTest/images-SP7/repo/SUSE-Multi-Linux-Manager-Proxy-SLE-5.2-POOL-x86_64-Media1/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE:/SLE-15-SP7:/Update:/Products:/MultiLinuxManager52:/ToTest/images-SP7/repo/SUSE-Multi-Linux-Manager-Proxy-SLE-5.2-POOL-x86_64-Media1/repodata/repomd.xml.key
{% else %} # head
proxy_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/Devel:/Galaxy:/Manager:/Main:/MLM-Beta-Products-SLE15/images/repo/SUSE-Multi-Linux-Manager-Proxy-SLE-5.2-POOL-x86_64-Media1/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/Devel:/Galaxy:/Manager:/Main:/MLM-Beta-Products-SLE15/images/repo/SUSE-Multi-Linux-Manager-Proxy-SLE-5.2-POOL-x86_64-Media1/repodata/repomd.xml.key
{% endif %}

ca_suse_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/SUSE:/CA/SLE_15_SP7
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/SUSE:/CA/SLE_15_SP7/repodata/repomd.xml.key

containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/15-SP7/x86_64/product
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/15-SP7/x86_64/product/repodata/repomd.xml.key

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/15-SP7/x86_64/update
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/15-SP7/x86_64/update/repodata/repomd.xml.key

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

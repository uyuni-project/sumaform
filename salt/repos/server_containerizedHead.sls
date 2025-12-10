{% if 'server_containerized' in grains.get('roles')  %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SLES' %}

server_devel_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/Multi-Linux-Manager-Server-5.2-x86_64/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/Multi-Linux-Manager-Server-5.2-x86_64/repodata/repomd.xml.key

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

{% endif %}
{% endif %}
{% endif %}


# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []


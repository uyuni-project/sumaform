{% if 'server_containerized' in grains.get('roles')  %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SL-Micro' %}

{% if '5.2-released' in grains['product_version'] %}
# Commented out because we already add this repo in cloud-init:
# container_utils_pool_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/Multi-Linux-Manager-Server/5.2/{{ grains.get("cpuarch") }}/product
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/Multi-Linux-Manager-Server/5.2/{{ grains.get("cpuarch") }}/product/repodata/repomd.xml.key
# container_utils_updates_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/Multi-Linux-Manager-Server/5.2/{{ grains.get("cpuarch") }}/update
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/Multi-Linux-Manager-Server/5.2/{{ grains.get("cpuarch") }}/update/repodata/repomd.xml.key
{% endif %}

{% elif grains['osfullname'] == 'SLES' %}
ca_suse_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/SUSE:/CA/SLE_15_SP7
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/SUSE:/CA/SLE_15_SP7/repodata/repomd.xml.key

containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/15-SP7/{{ grains.get("cpuarch") }}/product
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/15-SP7/{{ grains.get("cpuarch") }}/product/repodata/repomd.xml.key

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/15-SP7/{{ grains.get("cpuarch") }}/update
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/15-SP7/{{ grains.get("cpuarch") }}/update/repodata/repomd.xml.key

{% if '5.2-released' in grains['product_version'] %}
container_utils_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/Multi-Linux-Manager-Server-SLE/5.2/{{ grains.get("cpuarch") }}/product
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/Multi-Linux-Manager-Server-SLE/5.2/{{ grains.get("cpuarch") }}/product/repodata/repomd.xml.key
container_utils_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/Multi-Linux-Manager-Server-SLE/5.2/{{ grains.get("cpuarch") }}/update
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/Multi-Linux-Manager-Server-SLE/5.2/{{ grains.get("cpuarch") }}/update/repodata/repomd.xml.key
{% endif %}

{% endif %}
{% endif %}
{% endif %}


# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

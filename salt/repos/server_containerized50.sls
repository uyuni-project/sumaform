{% if 'server_containerized' in grains.get('roles')  %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SLE Micro' %}

{% if '5.0-released' in grains['product_version'] %}
# Commented out because we already add this repo in cloud-init:
# container_utils_pool_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SUSE-Manager-Server/5.0/x86_64/product
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SUSE-Manager-Server/5.0/x86_64/product/repodata/repomd.xml.key
# container_utils_updates_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SUSE-Manager-Server/5.0/x86_64/update
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SUSE-Manager-Server/5.0/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% if '5.0-nightly' in grains['product_version'] %}
# Commented out because we already add this repo in cloud-init:
# manager50_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/Devel:/Galaxy:/Manager:/5.0/images/repo/SUSE-Manager-Server-5.0-POOL-x86_64-Media1
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/Devel:/Galaxy:/Manager:/5.0/images/repo/SUSE-Manager-Server-5.0-POOL-x86_64-Media1/repodata/repomd.xml.key
{% endif %}

{% elif grains['osfullname'] == 'SLES' %}
ca_suse_repo:
  pkgrepo.managed:
    - baseurl: http://${ use_mirror_images ? mirror : "download.opensuse.org" }/repositories/SUSE:/CA/SLE_15_SP6
    - refresh: True
    - gpgkey: http://${ use_mirror_images ? mirror : "download.opensuse.org" }/repositories/SUSE:/CA/SLE_15_SP6/repodata/repomd.xml.key

containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/SUSE/Products/SLE-Module-Containers/15-SP6/x86_64/product
    - refresh: True
    - gpgkey: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/SUSE/Products/SLE-Module-Containers/15-SP6/x86_64/product/repodata/repomd.xml.key

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/SUSE/Updates/SLE-Module-Containers/15-SP6/x86_64/update
    - refresh: True
    - gpgkey: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/SUSE/Updates/SLE-Module-Containers/15-SP6/x86_64/update/repodata/repomd.xml.key

{% if '5.0-released' in grains['product_version'] %}
container_utils_pool_repo:
  pkgrepo.managed:
    - baseurl: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/SUSE/Products/SUSE-Manager-Server/5.0/x86_64/product
    - refresh: True
    - gpgkey: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/SUSE/Products/SUSE-Manager-Server/5.0/x86_64/product/repodata/repomd.xml.key

container_utils_updates_repo:
  pkgrepo.managed:
    - baseurl: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/SUSE/Updates/SUSE-Manager-Server/5.0/x86_64/update
    - refresh: True
    - gpgkey: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/SUSE/Updates/SUSE-Manager-Server/5.0/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% if '5.0-nightly' in grains['product_version'] %}
container_utils_repo:
  pkgrepo.managed:
    - baseurl: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/Devel:/Galaxy:/Manager:/5.0/images/repo/SUSE-Manager-Server-5.0-POOL-x86_64-Media1
    - refresh: True
    - gpgkey: http://${ use_mirror_images ? mirror : "dist.nue.suse.com/ibs" }/Devel:/Galaxy:/Manager:/5.0/images/repo/SUSE-Manager-Server-5.0-POOL-x86_64-Media1/repodata/repomd.xml.key
{% endif %}

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

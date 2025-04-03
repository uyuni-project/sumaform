{% if 'proxy_containerized' in grains.get('roles') %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SLE Micro' %}

{% if '5.0-released' in grains['product_version'] %}
# Commented out because we already add this repo in cloud-init:
# manager50_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE:/SLE-15-SP5:/Update:/Products:/Manager50/images/repo/SUSE-Manager-Proxy-5.0-POOL-x86_64-Media1/
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE:/SLE-15-SP5:/Update:/Products:/Manager50/images/repo/SUSE-Manager-Proxy-5.0-POOL-x86_64-Media1/repodata/repomd.xml.key
{% endif %}

{% if '5.0-nightly' in grains['product_version'] %}
# Commented out because we already add this repo in cloud-init:
# manager50_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0/images/repo/SUSE-Manager-Proxy-5.0-POOL-x86_64-Media1
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0/images/repo/SUSE-Manager-Proxy-5.0-POOL-x86_64-Media1/repodata/repomd.xml.key
{% endif %}

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

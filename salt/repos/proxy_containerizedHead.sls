{% if 'proxy_containerized' in grains.get('roles') %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SL-Micro' %}


# Commented out because we already add this repo in cloud-init:
# proxy_devel_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/SUSE-Manager-Proxy-5.2-x86_64/
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/SUSE-Manager-Proxy-5.2-x86_64/repodata/repomd.xml.key

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

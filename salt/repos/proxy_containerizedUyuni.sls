{% if 'proxy_containerized' in grains.get('roles') and 'uyuni' in grains.get('product_version') %}

# TODO: Remove this SLS file once we add support for Leap Micro 5.5 images in K3s, and we move this repository to cloud-init phase
#       This only affects Uyuni, as we use slemicro55o image for Head/5.0

{% if grains.get("os") == "SUSE" %}
{% if grains['osfullname'] == 'openSUSE Leap Micro' %}
{% set repo = 'openSUSE_Leap_Micro_5.5' %}

{% if 'uyuni' in grains['product_version'] %}
# Commented out because we already add this repo in combustion:
# containerutils_uyuni_stable:
#     pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/{{ repo }}/
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key
{% endif %}

{% if 'uyuni-master' in grains.get('product_version') %}
# Commented out because we already add this repo in combustion:
# containerutils_uyuni_master:
#     pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key
{% endif %}

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

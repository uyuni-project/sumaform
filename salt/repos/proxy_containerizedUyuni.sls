{% if 'proxy_containerized' in grains.get('roles') and 'uyuni' in grains.get('product_version') %}

# TODO: Remove this SLS file once we add support for Leap Micro 5.5 images, and we move this repository to cloud-init phase
#       This only affects Uyuni, as we use slemicro55o image for Head/5.0

{% if grains.get("os") == "SUSE" %}
{% if grains['osfullname'] == 'Leap' %}
{% set repo = 'openSUSE_Leap_15.5' %}

systemsmanagement_Uyuni_Master_ContainerUtils:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

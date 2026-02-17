{% if 'server_containerized' in grains.get('roles') and 'uyuni' in grains.get('product_version') %}

{% if grains['osfullname'] == 'openSUSE Tumbleweed' %}
{% set repo = 'openSUSE_Tumbleweed' %}

{% if 'uyuni-released' == grains['product_version'] %}
containerutils_uyuni_stable:
    pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/{{ repo }}/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key
{% endif %}

{% if 'uyuni-master' == grains.get('product_version') %}
containerutils_uyuni_master:
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


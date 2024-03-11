{% if 'server_containerized' in grains.get('roles')  %}

{% if grains.get("os") == "SUSE" %}
{% if grains['osfullname'] == 'Leap' %}
{% set repo = 'openSUSE_Leap_15.5' %}
{% elif grains['osfullname'].startswith('SLE') %}
{% set repo = 'SLE_15' %}
{% else %}
{% set repo = 'openSUSE_Leap_Micro_5.5' %}
{% endif %}

{% if 'Leap_Micro' not in repo %} 
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


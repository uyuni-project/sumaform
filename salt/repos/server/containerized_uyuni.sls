{% if grains['osfullname'] == 'Leap' %}
  {% set repo = 'openSUSE_Leap_15.5' %}

systemsmanagement_Uyuni_Master_ContainerUtils:
    pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

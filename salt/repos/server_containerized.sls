{% if 'server_containerized' in grains.get('roles')  %}

systemsmanagement_Uyuni_Master_ContainerUtils:
    pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/openSUSE_Leap_15.5/
    - refresh: True

{% endif %}


# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

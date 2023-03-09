{% if 'server_containerized' in grains.get('roles') %}

home_mbussolotto_branches_systemsmanagement_Uyuni_Master:
    pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/home:/mbussolotto:/branches:/systemsmanagement:/Uyuni:/Master/openSUSE_Leap_15.4/
    - refresh: True

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

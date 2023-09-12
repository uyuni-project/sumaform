{% if 'server_containerized' in grains.get('roles')  %}

systemsmanagement_Uyuni_Master_ServerContainer:
    pkgrepo.managed:
      # TODO change to the regular URL once available
    - baseurl: http://downloadcontent.opensuse.org/repositories/systemsmanagement:/Uyuni:/Master:/ServerContainer/openSUSE_Leap_15.4/
    - refresh: True

{% endif %}


# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

{% if 'server_containerized' in grains.get('roles') and grains.get('container_runtime') | default('podman', true) == 'podman' %}

systemsmanagement_Uyuni_Master_ServerContainer:
    pkgrepo.managed:
      # TODO change to the regular URL once available
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ServerContainer/openSUSE_Leap_15.4/
    - refresh: True

{% endif %}


# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

{% if grains.get('role') == 'controller' %}

Devel_Galaxy_cucumber_testsuite_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/repodata/repomd.xml.key

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

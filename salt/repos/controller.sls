{% if grains.get('role') == 'controller' %}

Devel_Galaxy_cucumber_testsuite_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_cucumber_testsuite.repo
    - source: salt://repos/repos.d/Devel_Galaxy_cucumber_testsuite.repo
    - template: jinja

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

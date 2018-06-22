{% if grains.get('role') == 'evil_minions' %}

tools_repo:
  file.managed:
    - name: /etc/zypp/repos.d/systemsmanagement-sumaform-tools.repo
    - source: salt://repos/repos.d/systemsmanagement-sumaform-tools.repo
    - template: jinja

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

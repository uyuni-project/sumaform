{% if grains.get('role') == 'grafana' %}

tools_repo:
  file.managed:
    - name: /etc/zypp/repos.d/systemsmanagement-sumaform-tools.repo
    - source: salt://repos/repos.d/systemsmanagement-sumaform-tools.repo
    - template: jinja

monitoring_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Monitoring.repo
    - source: salt://repos/repos.d/Monitoring.repo
    - template: jinja

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

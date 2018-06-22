{% if grains.get('role') == 'grafana' %}

tools_repo:
  file.managed:
    - name: /etc/zypp/repos.d/systemsmanagement-sumaform-tools.repo
    - source: salt://repos/repos.d/systemsmanagement-sumaform-tools.repo
    - template: jinja

refresh_grafana_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: tools_repo

{% endif %}

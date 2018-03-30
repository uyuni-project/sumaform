include:
  - default

tools_repo:
  file.managed:
    - name: /etc/zypp/repos.d/systemsmanagement-sumaform-tools.repo
    - source: salt://default/repos.d/systemsmanagement-sumaform-tools.repo
    - template: jinja
    - require:
      - sls: default

refresh_tools_repo:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: tools_repo

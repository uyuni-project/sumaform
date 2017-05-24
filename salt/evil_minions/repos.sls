include:
  - default

tools_repo:
  file.managed:
    - name: /etc/zypp/repos.d/home_SilvioMoioli_tools.repo
    - source: salt://evil_minions/repos.d/home_SilvioMoioli_tools.repo
    - template: jinja
    - require:
      - sls: default

refresh_tools_repo:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: tools_repo

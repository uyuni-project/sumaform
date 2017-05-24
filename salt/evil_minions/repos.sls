include:
  - default

evil_minions_repo:
  file.managed:
    - name: /etc/zypp/repos.d/home:PSuarezHernandez.repo
    - source: salt://evil_minions/repos.d/home:PSuarezHernandez.repo
    - template: jinja
    - require:
      - sls: default

refresh_evil_minions_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: evil_minions_repo

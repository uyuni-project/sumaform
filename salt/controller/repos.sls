include:
  - default

Devel_Galaxy_cucumber_testsuite_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_cucumber_testsuite.repo
    - source: salt://controller/repos.d/Devel_Galaxy_cucumber_testsuite.repo
    - template: jinja
    - require:
      - sls: default

refresh_controller_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: Devel_Galaxy_cucumber_testsuite_repo

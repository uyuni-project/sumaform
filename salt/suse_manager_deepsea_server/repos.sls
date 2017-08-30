include:
  - suse_manager_server.repos

ses5_repo:
  file.managed:
    - name: /etc/zypp/repos.d/ses5.repo
    - source: salt://suse_manager_deepsea_server/repos.d/ses5.repo
    - template: jinja
    - require:
      - sls: suse_manager_server.repos

tmate_repo:
  file.managed:
    - name: /etc/zypp/repos.d/tmate.repo
    - source: salt://suse_manager_deepsea_server/repos.d/tmate.repo
    - template: jinja
    - require:
      - sls: suse_manager_server.repos

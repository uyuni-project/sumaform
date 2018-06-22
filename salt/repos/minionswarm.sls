include:
  - default

suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default

refresh_suse_manager_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: suse_manager_pool_repo
      - file: suse_manager_update_repo

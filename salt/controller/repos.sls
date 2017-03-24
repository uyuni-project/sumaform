include:
  - default

ruby_test_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_ruby_test.repo
    - source: salt://controller/repos.d/Devel_Galaxy_ruby_test.repo
    - template: jinja
    - require:
      - sls: default

sle_12_sp1_sdk_pool:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-SDK-x86_64-Pool.repo
    - source: salt://controller/repos.d/SLE-12-SP1-SDK-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

refresh_controller_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: ruby_test_repo
      - file: sle_12_sp1_sdk_pool

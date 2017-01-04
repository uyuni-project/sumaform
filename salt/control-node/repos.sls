include:
  - default

ruby-test-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_ruby_test.repo
    - source: salt://control-node/repos.d/Devel_Galaxy_ruby_test.repo
    - template: jinja

sle-12-sp1-sdk-pool:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-SDK-x86_64-Pool.repo
    - source: salt://control-node/repos.d/SLE-12-SP1-SDK-x86_64-Pool.repo
    - template: jinja

refresh-control-node-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: default
      - file: ruby-test-repo
      - file: sle-12-sp1-sdk-pool

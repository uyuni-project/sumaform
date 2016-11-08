Ruby-test-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_ruby_test.repo
    - source: salt://control-node/repos.d/Devel_Galaxy_ruby_test.repo
    - template: jinja

SLE-12-SP1-SDK:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-SDK-GM.repo
    - source: salt://control-node/repos.d/SLE-12-SP1-SDK-GM.repo
    - template: jinja

# FIXME: we need this repo only for twopence/lavanda, in future just move this package to galaxy-rubyrepo
Slenkins-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_SLEnkins.repo
    - source: salt://control-node/repos.d/Devel_SLEnkins.repo
    - template: jinja

SLE-update:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-UPDATE.repo
    - source: salt://control-node/repos.d/SLE-UPDATE.repo
    - template: jinja

refresh-control-node-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh

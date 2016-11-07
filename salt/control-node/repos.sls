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

# FIXME: we need this repo only for twopence, in future just move this package to galaxy-rubyrepo
Slenkins-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_SLEnkins.repo
    - source: salt://control-node/repos.d/Devel_SLEnkins.repo
    - template: jinja

# FIXME: we need this repo, because some gems are not building on the repo sles-12-sp1.
# the spec file should be fixed.. 
SLE-12-UPDATE:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-x86_64-Update.repo
    - source: salt://control-node/repos.d/SLE-12-x86_64-Update.repo 
    - template: jinja

refresh-control-node-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh

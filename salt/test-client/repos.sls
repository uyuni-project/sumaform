buildRepo-needForTests:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://test-client/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

refresh-test-client-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh

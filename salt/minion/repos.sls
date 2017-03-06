centos-salt-pkg:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE_RES-7_Update_standard.repo
    - source: salt://minion/repos.d/SUSE_RES-7.repo
    - template: jinja

refresh-client-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh

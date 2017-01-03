opensuse-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-42.2-Pool.repo
    - source: salt://package-mirror/repos.d/openSUSE-Leap-42.2-Pool.repo
    - template: jinja

opensuse-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-42.2-Update.repo
    - source: salt://package-mirror/repos.d/openSUSE-Leap-42.2-Update.repo
    - template: jinja

refresh-package-mirror-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: opensuse-pool-repo
      - file: opensuse-update-repo

opensuse-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-42.1-Pool.repo
    - source: salt://package-mirror/repos.d/openSUSE-Leap-42.1-Pool.repo
    - template: jinja

opensuse-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-42.1-Update.repo
    - source: salt://package-mirror/repos.d/openSUSE-Leap-42.1-Update.repo
    - template: jinja

lftp-repo:
  file.managed:
    - name: /etc/zypp/repos.d/home_SilvioMoioli_tools.repo
    - source: salt://package-mirror/repos.d/home_SilvioMoioli_tools.repo

refresh-package-mirror-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: opensuse-pool-repo
      - file: opensuse-update-repo
      - file: lftp-repo

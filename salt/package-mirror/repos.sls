include:
  - sles.repos

lftp-repo:
  file.managed:
    - name: /etc/zypp/repos.d/home_SilvioMoioli_tools.repo
    - source: salt://package-mirror/repos.d/home_SilvioMoioli_tools.repo

refresh-package-mirror-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: sles.repos
      - file: lftp-repo

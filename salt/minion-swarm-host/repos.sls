include:
  - sles.repos

docker-repo:
  file.managed:
    - name: /etc/zypp/repos.d/docker.repo
    - source: salt://minion-swarm-host/repos.d/docker.repo

python-repo:
  file.managed:
    - name: /etc/zypp/repos.d/python.repo
    - source: salt://minion-swarm-host/repos.d/python.repo

refresh-minion-swarm-host-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: sles.repos
      - file: docker-repo
      - file: python-repo

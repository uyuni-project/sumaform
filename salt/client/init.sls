include:
  - client.repos

refresh-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: client.repos

wget:
  pkg.installed

/root/bootstrap.sh:
  file.managed:
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh.sha512
    - mode: 755
  cmd.run:
    - require:
      - file: /root/bootstrap.sh
      - pkg: wget

include:
  - client.repos

wget:
  pkg.installed:
    - require:
      - sls: client.repos

bootstrap-script:
  file.managed:
    - name: /root/bootstrap.sh
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh.sha512
    - mode: 755
  cmd.run:
    - name: /root/bootstrap.sh
    - require:
      - file: bootstrap-script
      - pkg: wget

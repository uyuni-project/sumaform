# Run with:
# sudo salt-call --local state.sls client.sles12_osad

/root/bootstrap-sles12-osad.sh:
  file.managed:
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap-sles12-osad.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap-sles12-osad.sh.sha512
    - mode: 755
  cmd.run:
    - require:
      - file: /root/bootstrap-sles12-osad.sh

rhnsd:
  service.dead:
    - enable: False

osad:
  service.running:
    - enable: True

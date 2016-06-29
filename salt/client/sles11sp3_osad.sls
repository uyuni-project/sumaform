# Run with:
# sudo salt-call --local state.sls client.sles11sp3_osad

/root/bootstrap-sles11sp3-osad.sh:
  file.managed:
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap-sles11sp3-osad.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap-sles11sp3-osad.sh.sha512
    - mode: 755
  cmd.run:
    - require:
      - file: /root/bootstrap-sles11sp3-osad.sh

rhnsd:
  service.dead:
    - enable: False

osad:
  service.running:
    - enable: True

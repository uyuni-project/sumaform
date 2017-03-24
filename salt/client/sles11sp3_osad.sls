# Run with:
# sudo salt-call --local state.sls client.sles11sp3_osad

osad_bootstrap_script:
  file.managed:
    - name: /root/bootstrap-sles11sp3-osad.sh
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap-sles11sp3-osad.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap-sles11sp3-osad.sh.sha512
    - mode: 755
  cmd.run:
    - name: /root/bootstrap-sles11sp3-osad.sh
    - require:
      - file: osad_bootstrap_script

rhnsd:
  service.dead:
    - enable: False

osad:
  service.running:
    - enable: True

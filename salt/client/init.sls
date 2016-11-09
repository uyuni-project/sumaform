include:
  - client.repos
  - client.testsuite

wget:
  pkg.installed:
    - require:
      - sls: client.repos

{% if grains['for-development-only'] %}

base-bootstrap-script:
  file.managed:
    - name: /root/bootstrap.sh
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh.sha512
    - mode: 755

bootstrap-script:
  file.replace:
    - name: /root/bootstrap.sh
    - pattern: ^PROFILENAME="".*$
    - repl: PROFILENAME="{{grains['fqdn']}}"
    - require:
      - file: base-bootstrap-script
  cmd.run:
    - name: /root/bootstrap.sh
    - require:
      - file: bootstrap-script
      - pkg: wget

{% endif %}

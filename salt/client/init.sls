include:
  - client.testsuite

wget:
  pkg.installed:
    - require:
      - sls: default

{% if grains.get('auto_register') | default(true, true) %}

base_bootstrap_script:
  file.managed:
    - name: /root/bootstrap.sh
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh.sha512
    - mode: 755

bootstrap_script:
  file.replace:
    - name: /root/bootstrap.sh
    - pattern: ^PROFILENAME="".*$
    {% if grains['hostname'] and grains['domain'] %}
    - repl: PROFILENAME="{{ grains['hostname'] }}.{{ grains['domain'] }}"
    {% else %}
    - repl: PROFILENAME="{{grains['fqdn']}}"
    {% endif %}
    - require:
      - file: base_bootstrap_script
  cmd.run:
    - name: /root/bootstrap.sh
    - require:
      - file: bootstrap_script
      - pkg: wget

{% endif %}

{% if grains.get('java_debugging') %}

include:
  - server.rhn

taskomatic_config:
  file.replace:
    - name: /etc/rhn/taskomatic.conf
    - pattern: JAVA_OPTS=""
    {% if grains['hostname'] and grains['domain'] %}
    - repl: JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address={{ grains['hostname'] }}.{{ grains['domain'] }}:8001,server=y,suspend=n"
    {% else %}
    - repl: JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address={{ grains['fqdn'] }}:8001,server=y,suspend=n"
    {% endif %}
    - require:
      - sls: server.rhn

{% endif %}

taskomatic:
  service.running:
    - watch:
      - file: /etc/rhn/rhn.conf
     {% if grains.get('monitored') | default(false, true) %}
      - file: jmx_taskomatic_config
     {% endif %}

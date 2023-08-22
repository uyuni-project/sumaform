{% if grains.get('java_debugging') %}

include:
  - server.rhn

taskomatic_config:
  file.replace:
    - name: /etc/rhn/taskomatic.conf
    - pattern: JAVA_OPTS=""
    - repl: JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=*:8001,server=y,suspend=n "
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

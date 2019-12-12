{% if grains.get('java_debugging') %}

include:
  - server.rhn

tomcat_config:
  file.replace:
    - name: /etc/sysconfig/tomcat
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    {% if grains['hostname'] and grains['domain'] %}
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address={{ grains['hostname'] }}.{{ grains['domain'] }}:8000,server=y,suspend=n -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['hostname'] }}.{{ grains['domain'] }} \1"'
    {% else %}
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address={{ grains['fqdn'] }}:8000,server=y,suspend=n -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['fqdn'] }} \1"'
    {% endif %}
    - require:
      - sls: server.rhn

{% endif %}

tomcat_service:
  service.running:
    - name: tomcat
    - watch:
      {% if grains.get('java_debugging') %}
      - file: tomcat_config
      {% endif %}
      - file: /etc/rhn/rhn.conf

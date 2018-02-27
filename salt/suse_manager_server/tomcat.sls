{% if grains['for_development_only'] %}

include:
  - suse_manager_server

tomcat_config:
  file.replace:
    - name: /etc/tomcat/tomcat.conf
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    {% if grains['hostname'] and grains['domain'] %}
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['hostname'] }}.{{ grains['domain'] }} \1"'
    {% else %}
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['fqdn'] }} \1"'
    {% endif %}
    - require:
      - sls: suse_manager_server

{% if '3.0' not in grains['version'] %}
tomcat_config_loaded:
  file.comment:
    - name: /etc/tomcat/tomcat.conf
    - regex: '^TOMCAT_CFG_LOADED.*'
    - require:
      - sls: suse_manager_server
{% endif %}

tomcat_service:
  service.running:
    - name: tomcat
    - watch:
      - file: tomcat_config
    - require:
      - file: tomcat_config

{% endif %}

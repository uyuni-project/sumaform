{% if grains.get('java_debugging') %}

include:
  - suse_manager_server.rhn

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
      - sls: suse_manager_server.rhn

{% if '3.0' not in grains['version'] %}
tomcat_config_loaded:
  file.comment:
    - name: /etc/tomcat/tomcat.conf
    - regex: '^TOMCAT_CFG_LOADED.*'
    - require:
      - sls: suse_manager_server.rhn
{% endif %}

{% endif %}

tomcat_service:
  service.running:
    - name: tomcat
    - watch:
      {% if grains.get('java_debugging') %}
      - file: /etc/tomcat/tomcat.conf
      {% endif %}
      - file: /etc/rhn/rhn.conf
      # HACK: temporary workaround for bsc#1085921
      - file: java_policy_local_link
      - file: java_policy_US_link

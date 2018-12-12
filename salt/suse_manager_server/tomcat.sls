{% if grains.get('java_debugging') %}

include:
  - suse_manager_server.rhn

tomcat_config:
  file.replace:
    {% if '3.0' in grains['product_version'] %}
    - name: /etc/tomcat/tomcat.conf
    {% else %}
    - name: /etc/sysconfig/tomcat
    {% endif %}
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    {% if grains['hostname'] and grains['domain'] %}
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['hostname'] }}.{{ grains['domain'] }} \1"'
    {% else %}
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['fqdn'] }} \1"'
    {% endif %}
    - require:
      - sls: suse_manager_server.rhn

{% endif %}

# HACK: temporary workaround for bsc#1119213
java-1_8_0-ibm:
  pkg.installed:
    - version: 1.8.0_sr5.20-30.36.1

tomcat_service:
  service.running:
    # HACK: Temporary workaround for bsc#1119213
    - name: tomcat
    - watch:
      - pkg: java-1_8_0-ibm
      {% if grains.get('java_debugging') %}
      - file: tomcat_config
      {% endif %}
      - file: /etc/rhn/rhn.conf

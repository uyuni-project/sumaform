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

hibernate_debug_log:
  file.line:
    - name: /srv/tomcat/webapps/rhn/WEB-INF/classes/log4j2.xml
    - content: '    <Logger name="org.hibernate" level="debug" additivity="false"><AppenderRef ref="hibernateAppender" /></Logger>'
    - after: "<Loggers>"
    - mode: ensure
    - require:
      - sls: server.rhn

taskomatic_hibernate_debug_log:
  file.line:
    - name: /srv/tomcat/webapps/rhn/WEB-INF/classes/log4j2.xml
    - content: '    <File name="hibernateAppender" fileName="/var/log/rhn/rhn_taskomatic_hibernate.log"><PatternLayout pattern="[%d] %-5p - %m%n" /></File>'
    - after: "<Appenders>"
    - mode: ensure
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

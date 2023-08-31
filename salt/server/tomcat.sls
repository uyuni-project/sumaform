{% if grains.get('java_debugging') %}

include:
  - server.rhn

tomcat_config_create:
  file.touch:
    - name: /etc/tomcat/conf.d/remote_debug.conf
    - makedirs: True

tomcat_config:
  file.replace:
    - name: /etc/tomcat/conf.d/remote_debug.conf
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    - repl: 'JAVA_OPTS=" $JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=*:8000,server=y,suspend=n "'
    - append_if_not_found: True
    - ignore_if_missing: True
    - require:
      - sls: server.rhn
      - file: tomcat_config_create

salt_server_action_service_debug_log:
  file.line:
    - name: /srv/tomcat/webapps/rhn/WEB-INF/classes/log4j2.xml
    - content: '    <Logger name="com.suse.manager.webui.services.SaltServerActionService" level="trace" />'
    - after: "<Loggers>"
    - mode: ensure
    - require:
      - sls: server.rhn
{% endif %}

{% if grains.get('login_timeout') %}
extend_tomcat_login_timeout:
  file.replace:
    - name: /srv/tomcat/webapps/rhn/WEB-INF/web.xml
    - pattern: <session-timeout>*
    - repl: <session-timeout>{{ grains['login_timeout'] // 60 }}</session-timeout>
    - append_if_not_found: True
    - require:
        - cmd: server_setup
{% endif %}

tomcat_service:
  service.running:
    - name: tomcat
    - watch:
      {% if grains.get('java_debugging') %}
      - file: tomcat_config
      {% endif %}
      - file: /etc/rhn/rhn.conf
      {% if grains.get('monitored') | default(false, true) %}
      - file: jmx_tomcat_config
      {% endif %}

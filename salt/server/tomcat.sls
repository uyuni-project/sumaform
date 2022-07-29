{% if grains.get('java_debugging') %}

include:
  - server.rhn

tomcat_config:
  file.replace:
    - name: /etc/sysconfig/tomcat
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    {% if grains.get('hostname') and grains.get('domain') %}
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address={{ grains['hostname'] }}.{{ grains['domain'] }}:8000,server=y,suspend=n \1"'
    {% else %}
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address={{ grains['fqdn'] }}:8000,server=y,suspend=n \1"'
    {% endif %}
    - require:
      - sls: server.rhn

tomcat_config_jmx:
  file.append:
    - name: /etc/sysconfig/tomcat
    {% if grains.get('hostname') and grains.get('domain') %}
    - text: |

        # Add these options and restart tomcat for remote monitoring via Java Managent Extensions (JMX)
        # -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['hostname'] }}.{{ grains['domain'] }}
    {% else %}
    - text: |

        # Add these options and restart tomcat for remote monitoring via Java Managent Extensions (JMX)
        # -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['fqdn'] }}
    {% endif %}
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

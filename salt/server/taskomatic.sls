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

taskomatic_config_jmx:
  file.append:
    - name: /etc/rhn/taskomatic.conf
    {% if grains['hostname'] and grains['domain'] %}
    - text: |

        # Add these options and restart taskomatic for remote monitoring via Java Managent Extensions (JMX)
        # -Dcom.sun.management.jmxremote.port=3334 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['hostname'] }}.{{ grains['domain'] }}
    {% else %}
    - text: |

        # Add these options and restart taskomatic for remote monitoring via Java Managent Extensions (JMX)
        # -Dcom.sun.management.jmxremote.port=3334 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ grains['fqdn'] }}
    {% endif %}
    - require:
      - sls: server.rhn

{% endif %}

taskomatic:
  service.running:
    - watch:
      - file: /etc/rhn/rhn.conf
      - file: /usr/lib/systemd/system/taskomatic.service.d/*

{% if grains.get('java_debugging') %}

include:
  - suse_manager_server.rhn

taskomatic_config:
{% if grains['product_version'].startswith('3.') or grains['product_version'] == 'released' %}
  file.append:
    - name: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - text: |
        wrapper.java.additional.7=-Xdebug
        wrapper.java.additional.8=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n
        wrapper.java.additional.9=-Dcom.sun.management.jmxremote.port=3334
        wrapper.java.additional.10=-Dcom.sun.management.jmxremote.ssl=false
        wrapper.java.additional.11=-Dcom.sun.management.jmxremote.authenticate=false
        wrapper.java.additional.12=-Djava.rmi.server.hostname={{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
{% else %}
  file.replace:
    - name: /etc/rhn/taskomatic.conf
    - pattern: JAVA_OPTS="
    - repl: JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n -Dcom.sun.management.jmxremote.port=3334 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
{% endif %}
    - require:
      - sls: suse_manager_server.rhn

{% endif %}

taskomatic:
  service.running:
    - watch:
      {% if grains.get('java_debugging') and (grains['product_version'].startswith('3.') or grains['product_version'] == 'released') %}
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
      {% endif %}
      - file: /etc/rhn/rhn.conf

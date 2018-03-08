{% if grains.get('java_debugging') %}

include:
  - suse_manager_server

taskomatic_config:
  file.append:
    - name: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - text: |
        wrapper.java.additional.7=-Xdebug
        wrapper.java.additional.8=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n
        wrapper.java.additional.9=-Dcom.sun.management.jmxremote.port=3334
        wrapper.java.additional.10=-Dcom.sun.management.jmxremote.ssl=false
        wrapper.java.additional.11=-Dcom.sun.management.jmxremote.authenticate=false
        wrapper.java.additional.12=-Djava.rmi.server.hostname={{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
    - require:
      - sls: suse_manager_server

taskomatic:
  service.running:
    - watch:
      - file: taskomatic_config
    - require:
      - file: taskomatic_config

{% endif %}

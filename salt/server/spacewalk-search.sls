{% if grains.get('java_debugging') %}

include:
  - server

spacewalk_search_config:
  file.append:
    - name: /usr/share/rhn/config-defaults/rhn_search_daemon.conf
    - text: |
        wrapper.java.additional.1=-Xdebug
        wrapper.java.additional.2=-Xrunjdwp:transport=dt_socket,address=8002,server=y,suspend=n
        wrapper.java.additional.3=-Dcom.sun.management.jmxremote.port=3335
        wrapper.java.additional.4=-Dcom.sun.management.jmxremote.ssl=false
        wrapper.java.additional.5=-Dcom.sun.management.jmxremote.authenticate=false
        wrapper.java.additional.6=-Djava.rmi.server.hostname={{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
    - require:
      - sls: server

spacewalk-service:
  service.running:
    - name: spacewalk.target
    - watch:
      - file: spacewalk_search_config
    - require:
      - file: spacewalk_search_config

{% endif %}

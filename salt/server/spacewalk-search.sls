{% if grains.get('java_debugging') %}

include:
  - server

spacewalk_search_config:
  file.append:
    - name: /usr/share/rhn/config-defaults/rhn_search_daemon.conf
    - text: |
        JAVA_OPTS='-Xdebug -Xrunjdwp:transport=dt_socket,address=*:8002,server=y,suspend=n'
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

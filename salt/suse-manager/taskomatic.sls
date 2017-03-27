{% if grains['for_development_only'] %}

include:
  - suse-manager

taskomatic_config:
  file.append:
    - name: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - text: ['wrapper.java.additional.7=-Xdebug',
             'wrapper.java.additional.8=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n']
    - require:
      - sls: suse-manager

taskomatic:
  service.running:
    - watch:
      - file: taskomatic_config
    - require:
      - file: taskomatic_config

{% endif %}

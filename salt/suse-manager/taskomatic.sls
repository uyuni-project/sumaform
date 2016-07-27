{% if grains['for-development-only'] %}

include:
  - suse-manager

/usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf:
  file.append:
    - text: ['wrapper.java.additional.7=-Xdebug',
             'wrapper.java.additional.8=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n']
    - require:
      - sls: suse-manager

taskomatic:
  service.running:
    - watch:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - require:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf

{% endif %}

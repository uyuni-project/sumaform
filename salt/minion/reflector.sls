{% if grains.get('use_avahi') and grains.get('avahi_reflector') %}

reflector_configuration:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#enable-reflector=no"
    - repl: "enable-reflector=yes"

reflector_service:
  service.running:
    - name: avahi-daemon
    - enable: True
    - running: True
    - watch:
      - file: /etc/avahi/avahi-daemon.conf

{% endif %}

{% if grains.get('use_avahi') and grains.get('avahi_reflector') %}

# We upgrade to latest version because of a bug in Avahi:
#   https://github.com/lathiat/avahi/issues/117
# It does not remove the problem, but makes it less likely to happen
reflector_package:
  pkg.latest:
    - pkgs:
      {% if grains['os'] == 'SUSE' %}
      - avahi
      - avahi-lang
      - libavahi-common3
      - libavahi-core7
      {% elif grains['os'] == 'Ubuntu' %}
      - avahi-daemon
      - libavahi-common-data
      - libavahi-common3
      - libavahi-core7
      {% elif grains['os_family'] == 'RedHat' %}
      - avahi
      - avahi-libs
      {% endif %}
    - refresh: true

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

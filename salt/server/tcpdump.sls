{% if grains.get('saltapi_tcpdump', false) %}

tcpdump:
  pkg.installed

tcpdump.unit:
  file.managed:
    - name: /etc/systemd/system/tcpdump.service
    - require:
      - pkg: tcpdump
    - source: salt://server/tcpdump.service
    - user: root
    - group: root

tcpdump.service:
  service.running:
    - require:
      - file: tcpdump.unit
    - enable: True

{% endif %}

tcpdump:
  pkg.installed

tcpdump.unit:
  file.managed:
    - name: /etc/systemd/system/tcpdump.service
    - require:
      - pkg: tcpdump
    - source: salt://suse_manager_server/tcpdump.service
    - user: root
    - group: root

tcpdump.service:
  service.running:
    - require:
      - file: tcpdump.unit
    - enable: True

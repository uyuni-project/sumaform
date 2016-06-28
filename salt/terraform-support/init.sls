hostname:
  cmd.run:
    - name: hostname {{ grains['hostname'] }}.{{ grains['avahi-domain'] }}
  file.managed:
    - name: /etc/hostname
    - text: {{ grains['hostname'] }}.{{ grains['avahi-domain'] }}

hosts file:
  file.append:
    - name: /etc/hosts
    - text: "127.0.1.1 {{ grains['hostname'] }}.{{ grains['avahi-domain'] }} {{ grains['hostname'] }}"

avahi:
  pkg.installed:
    - name: avahi
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#domain-name=local"
    - repl: "domain-name={{ grains['avahi-domain'] }}"
  service.running:
    - name: avahi-daemon
    - require:
      - pkg: avahi
      - file: avahi
    - watch:
      - file: /etc/avahi/avahi-daemon.conf

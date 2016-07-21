hosts_file:
  file.append:
    - name: /etc/hosts
    - text: "127.0.1.1 {{ grains['hostname'] }}.{{ grains['domain'] }} {{ grains['hostname'] }}"

set_transient_hostname:
  cmd.run:
    - name: hostnamectl set-hostname {{ grains['hostname'] }}.{{ grains['domain'] }}
    - onlyif: hostnamectl

hostname:
  cmd.run:
    - name: hostname {{ grains['hostname'] }}.{{ grains['domain'] }}
  file.managed:
    - name: /etc/hostname
    - contents: {{ grains['hostname'] }}.{{ grains['domain'] }}

avahi:
  pkg.installed:
    - name: avahi
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#domain-name=local"
    - repl: "domain-name={{ grains['domain'] }}"
  service.running:
    - name: avahi-daemon
    - require:
      - pkg: avahi
      - file: avahi
    - watch:
      - file: /etc/avahi/avahi-daemon.conf

configure-full-avahi-resolution:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: "(hosts: .*?)mdns([46]?)_minimal(.*)"
    - repl: "\\1mdns\\2\\3"
    - require:
      - pkg: avahi

setup-machine-id:
  cmd.run:
    - name: rm /etc/machine-id && systemd-machine-id-setup && touch /etc/machine-id-already-setup
    - creates: /etc/machine-id-already-setup
    - onlyif: systemd-machine-id-setup

# HACK: workaround for https://infra.nue.suse.com/SelfService/Display.html?id=49948
work_around_networking_issue:
  cmd.run:
    - name: ping -c 1 euklid.suse.de; true

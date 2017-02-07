hosts-file:
  file.append:
    - name: /etc/hosts
    - text: "127.0.1.1 {{ grains['hostname'] }}.{{ grains['domain'] }} {{ grains['hostname'] }}"

set-temporary-hostname:
  cmd.run:
    {% if grains['init'] == 'systemd' %}
    - name: hostnamectl set-hostname {{ grains['hostname'] }}
    {% else %}
    - name: hostname {{ grains['hostname'] }}
    {% endif %}

set-permanent-hostname:
  file.managed:
    - name: /etc/hostname
    - contents: {{ grains['hostname'] }}

permanent-hostname-backward-compatibility-link:
  file.symlink:
    - name: /etc/HOSTNAME
    - force: true
    - target: /etc/hostname

{% if grains['use-avahi'] %}
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
{% endif %}

setup-machine-id-with-systemd:
  cmd.run:
    - name: rm /etc/machine-id && systemd-machine-id-setup && touch /etc/machine-id-already-setup
    - creates: /etc/machine-id-already-setup
    - onlyif: test -f /usr/bin/systemd-machine-id-setup

setup-machine-id-with-dbus:
  cmd.run:
    - name: dbus-uuidgen --ensure
    - creates: /var/lib/dbus/machine-id
    - unless: test -f /usr/bin/systemd-machine-id-setup

clear-minion-id:
  file.absent:
    - name: /etc/salt/minion_id

include:
  - default.hostname

avahi_pkg:
  pkg.installed:
    {%- if grains['os_family'] == 'Debian' %}
    - name: avahi-daemon
    {% else %}
    - name: avahi
    {% endif %}

avahi_change_domain:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#domain-name=local"
    - repl: "domain-name={{ grains['domain'] }}"
    - require:
      - pkg: avahi

avahi_restrict_interfaces:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#allow-interfaces=eth0"
    - repl: "allow-interfaces=eth0"
    - require:
      - pkg: avahi

mdns_declare_domains:
  file.append:
    - name: /etc/mdns.allow
    - text:
      - .local
      - .tf.local

nsswitch_enable_mdns:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: "(hosts: .*?)mdns([46]?)_minimal(.*)"
    - repl: "\\1mdns\\2\\3"

avahi_service:
  service.running:
    - name: avahi-daemon
    - require:
      - file: avahi_change_domain
      - file: avahi_restrict_interfaces
      - file: mdns_declare_domains
      - file: nsswitch_enable_mdns
    - watch:
      - file: /etc/avahi/avahi-daemon.conf

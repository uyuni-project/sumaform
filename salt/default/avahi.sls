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
      - pkg: avahi_pkg

avahi_restrict_interfaces:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#deny-interfaces=eth1"
    - repl: "deny-interfaces=eth1,ens4"
    - require:
      - pkg: avahi_pkg

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
      - file: mdns_declare_domains
      - file: nsswitch_enable_mdns
    - watch:
      - file: /etc/avahi/avahi-daemon.conf

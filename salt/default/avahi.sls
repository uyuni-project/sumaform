include:
  - default.hostname

{% if grains['use_avahi'] %}
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

{% if not grains.get('ipv6')['enable'] %}
avahi_disable_ipv6:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "use-ipv6=yes"
    - repl: "use-ipv6=no"
    - require:
      - pkg: avahi_pkg
{% endif %}

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

avahi_enable_service:
  service.running:
    - name: avahi-daemon
    - require:
      - file: mdns_declare_domains
      - file: nsswitch_enable_mdns
    - watch:
      - file: /etc/avahi/avahi-daemon.conf

{% else %}

nsswitch_disable_mdns:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: "(hosts: .*?)mdns([46]?)_minimal \\[NOTFOUND=return\\](.*)"
    - repl: "\\1\\3"

avahi_disable_service:
  service.dead:
    - name: avahi-daemon
    - enable: false

{% endif %}

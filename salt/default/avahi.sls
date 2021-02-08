include:
  - default.hostname

{% if grains['use_avahi'] and grains.get('osmajorrelease', None) != None %}

# TODO: remove the following state when fix to bsc#1163683 is applied to all the SLES versions we use
{% if grains['osfullname'] == 'SLES' %}
custom_avahi_repo:
  pkgrepo.managed:
    - humanname: custom_avahi_repo
    {% if grains['osmajorrelease']|int() == 11 %}
    - baseurl: http://download.opensuse.org/repositories/systemsmanagement:/sumaform:/tools:/avahi:/0.6.23/SLE_11_SP4/
    {% elif grains['osmajorrelease']|int() == 12 %}
    - baseurl: http://download.opensuse.org/repositories/systemsmanagement:/sumaform:/tools:/avahi:/0.6.32/SLE_12_SP4/
    {% else %}
    - baseurl: http://download.opensuse.org/repositories/systemsmanagement:/sumaform:/tools:/avahi:/0.7/SLE_15_SP1/
    {% endif %}
    - priority: 95
    - gpgcheck: 0
{% endif %}

# TODO: remove the following state when fix to bsc#1168306 is applied to SLES 15 SP2
{% if grains['osfullname'] == 'SLES' and grains['osrelease'] == '15.2' %}
apparmor_allow_avahi_custom_domains:
  pkg.installed:
    - name: apparmor-abstractions
  file.line:
    - name: /etc/apparmor.d/abstractions/nameservice
    - mode: insert
    - after: run/avahi-daemon/socket
    - content: "  /etc/mdns.allow         r,"
{% endif %}

{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease']|int() == 6 %}
dbus_enable_service:
  service.running:
    - name: messagebus
    - enable: true
{% endif %}

# TODO: replace 'pkg.latest' with 'pkg.installed' when fix to bsc#1163683 is applied to all the SLES versions we use
avahi_pkg:
  pkg.latest:
    - pkgs:
      {% if grains['os_family'] == 'Debian' %}
      - avahi-daemon
      - libavahi-common-data
      - libavahi-common3
      - libavahi-core7
      {% elif grains['os_family'] == 'RedHat' %}
      - avahi
      - avahi-libs
      - nss-mdns
      {% elif grains['os_family'] == 'Suse' %}
      - avahi
      - avahi-lang
      - libavahi-common3
      {% if grains['osmajorrelease']|int() == 11 %}
      - libavahi-core5
      {% else %}
      - libavahi-core7
      {% endif %}
      {% endif %}

# WORKAROUND: watch does not really work with Salt 2016.11
avahi_dead_before_config:
  service.dead:
    - name: avahi-daemon

avahi_change_domain:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#domain-name=local"
    - repl: "domain-name={{ grains['domain'] }}"

avahi_restrict_interfaces:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "#deny-interfaces=eth1"
    - repl: "deny-interfaces=eth1,ens4"

{% if not grains.get('ipv6')['enable'] %}
avahi_disable_ipv6:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "use-ipv6=yes"
    - repl: "use-ipv6=no"
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
    - enable: true

{% else %} # use_avahi is false

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

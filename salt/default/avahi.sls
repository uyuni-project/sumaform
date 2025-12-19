include:
  - default.hostname

{% if grains['use_avahi'] and grains.get('osmajorrelease', None) != None %}

# TODO: remove the following state when fix to bsc#1163683 is applied to all the SLES < SLES15SP4
{% if grains['osfullname'] == 'SLES' and grains['osrelease'] != '15.7' and grains['osrelease'] != '15.6' and grains['osrelease'] != '15.5' and grains['osrelease'] != '15.4' %}
custom_avahi_repo:
  pkgrepo.managed:
    - humanname: custom_avahi_repo
    {% if grains['osrelease'] == '12.5' %}
    - baseurl: http://download.opensuse.org/repositories/systemsmanagement:/sumaform:/tools:/avahi:/0.6.32/SLE_12_SP5/
    {% elif grains['osrelease'] == '15.3' %}
    - baseurl: http://download.opensuse.org/repositories/systemsmanagement:/sumaform:/tools:/avahi:/0.7/SLE_15_SP3/
    {% elif grains['osrelease'] == '15.4' %}
    - baseurl: http://download.opensuse.org/repositories/systemsmanagement:/sumaform:/tools:/avahi:/0.7/SLE_15_SP4/
    {% elif grains['osrelease'] == '15.5' %}
    - baseurl: http://download.opensuse.org/repositories/systemsmanagement:/sumaform:/tools:/avahi:/0.8/SLE_15_SP5/
    {% elif grains['osrelease'] == '15.6' %}
    - baseurl: http://download.opensuse.org/repositories/systemsmanagement:/sumaform:/tools:/avahi:/0.8/SLE_15_SP6/
    {% endif %}
    - enabled: True
    - refresh: True
    - priority: 95
    - gpgcheck: 0
{% endif %}

{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease']|int() == 6 %}
dbus_enable_service:
  service.running:
    - name: messagebus
    - enable: true
{% endif %}

# TODO: replace 'pkg.latest' with 'pkg.installed' when fix to bsc#1163683 is applied to all the SLES versions we use
{% if not (grains['os_family'] == 'Suse' and grains['osfullname'] in ['SLE Micro', 'SL-Micro']) %}
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
      - libavahi-common3
      {% if grains['osmajorrelease']|int() == 11 %}
      - libavahi-core5
      {% else %}
      - libavahi-core7
      {% endif %}
      {% endif %}
    - requires:
      - pkgrepo: os_pool_repo
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

# HACK: always disable IPv6 in avahi settings
# to work around https://github.com/lathiat/avahi/issues/110
# uncomment the following conditional when issue is fixed
# {% if not grains.get('ipv6')['enable'] %}
avahi_disable_ipv6:
  file.replace:
    - name: /etc/avahi/avahi-daemon.conf
    - pattern: "use-ipv6=yes"
    - repl: "use-ipv6=no"
# {% endif %}

mdns_declare_domains:
  file.append:
    - name: /etc/mdns.allow
    - text:
      - .local
      - .tf.local

# Logic for enabling mdns in nsswitch
{% if salt['file.directory_exists']('/etc/nsswitch.conf.d') %}
nsswitch_mdns_dropin:
  file.managed:
    - name: /etc/nsswitch.conf.d/99-sumaform.conf
    - contents: |
        # Added by sumaform to ensure mDNS works with local files
        hosts: files mdns4 dns
    - makedirs: True
{% else %}
nsswitch_enable_mdns:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: "(hosts: .*?)mdns([46]?)_minimal(.*)"
    - repl: "\\1mdns4\\3"
    - onlyif: test -f /etc/nsswitch.conf
{% endif %}

avahi_enable_service:
  service.running:
    - name: avahi-daemon
    - require:
      - file: mdns_declare_domains
      {% if salt['file.directory_exists']('/etc/nsswitch.conf.d') %}
      - file: nsswitch_mdns_dropin
      {% else %}
      - file: nsswitch_enable_mdns
      {% endif %}
    - enable: true

{% else %} # use_avahi is false

# Logic for disabling mdns in nsswitch
{% if salt['file.directory_exists']('/etc/nsswitch.conf.d') %}
nsswitch_mdns_dropin_absent:
  file.absent:
    - name: /etc/nsswitch.conf.d/99-sumaform.conf
{% else %}
nsswitch_disable_mdns:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: "(hosts: .*?)mdns([46]?)_minimal \\[NOTFOUND=return\\](.*)"
    - repl: "\\1\\3"
    - onlyif: test -f /etc/nsswitch.conf
{% endif %}

avahi_disable_service:
  service.dead:
    - name: avahi-daemon
    - enable: false

{% endif %}

include:
  - default.locale
  - default.minimal
  {% if not grains.get('no_install') | default(false) %}
  - default.pkgs
  {% endif %}
  {% if grains.get('reset_ids') | default(false, true) %}
  - default.ids
  {% endif %}
  - default.testsuite

timezone_package:
  pkg.installed:
{% if grains['os_family'] == 'Suse' %}
    - name: timezone
{% else %}
    - name: tzdata
{% endif %}

timezone_symlink:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/{{ grains['timezone'] }}
    - force: true
    - require:
      - pkg: timezone_package

timezone_setting:
  timezone.system:
    - name: {{ grains['timezone'] }}
    - utc: True
    - require:
      - file: timezone_symlink

{% if grains.get('use_os_unreleased_updates') | default(False, true) or grains.get('use_os_released_updates') | default(False, true) %}
update_packages:
  pkg.uptodate:
    - require:
      - sls: repos
{% endif %}

{% if grains.get('swap_file_size', "0")|int() > 0 %}
file_swap:
  cmd.run:
    - name: |
        {% if grains['os_family'] == 'RedHat' %}dd if=/dev/zero of=/extra_swapfile bs=1048576 count={{grains['swap_file_size']}}{% else %}fallocate --length {{grains['swap_file_size']}}MiB /extra_swapfile{% endif %}
        chmod 0600 /extra_swapfile
        mkswap /extra_swapfile
    - creates: /extra_swapfile
  mount.swap:
    - name: /extra_swapfile
    - persist: true
    - require:
      - cmd: file_swap
{% endif %}

{% if grains['authorized_keys'] %}
authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text:
{% for key in grains['authorized_keys'] %}
      - {{ key }}
{% endfor %}
    - makedirs: True
{% endif %}

{% if grains.get('ipv6')['enable'] | default('1') == '1' %}

ipv6_enable_all:
  sysctl.present:
    - name: net.ipv6.conf.all.disable_ipv6
    - value: 0

{# net.ipv6.conf.all.accept_ra cannot be used, we have to proceed one interface at a time #}
{% set ifaces = grains.get('ip6_interfaces').keys() %}

{% if grains.get('ipv6')['accept_ra'] | default('1') == '1' %}

{% for iface in ifaces %}
ipv6_accept_ra_{{ iface }}:
  sysctl.present:
    - name: net.ipv6.conf.{{ iface }}.accept_ra
    - value: 2
{% endfor %}

{% else %}

{% for iface in ifaces %}
ipv6_reject_ra_{{ iface }}:
  sysctl.present:
    - name: net.ipv6.conf.{{ iface }}.accept_ra
    - value: 0

delete_existing_dynamic_addresses_{{ iface }}:
  cmd.run:
    - name: |
        for dynaddr in $(ip -6 a s dev {{ iface }} | grep 'inet6 2' | awk '{print $2}'); do
          ip -6 a d $dynaddr dev {{ iface }}
        done

{% if grains['os'] == 'SUSE' %}
avoid_wicked_messing_up_{{ iface }}:
  file.replace:
    - name: /etc/sysconfig/network/ifcfg-{{ iface }}
    - pattern: "BOOTPROTO *= *[Dd][Hh][Cc][Pp] *$"
    - repl: "BOOTPROTO=dhcp4"
    - ignore_if_missing: true
{% endif %}
{% endfor %}

{% if grains['os'] == 'Ubuntu' %}
avoid_networkd_messing_up:
  file.append:
    - name: /etc/netplan/01-netcfg.yaml
    - text: "      accept-ra: no"
  cmd.run:
    - name: 'netplan apply'
{% endif %}

{% endif %}

{% else %}

ipv6_disable_all:
  sysctl.present:
    - name: net.ipv6.conf.all.disable_ipv6
    - value: 1

{% endif %}

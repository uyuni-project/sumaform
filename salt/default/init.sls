include:
  - default.minimal
  - default.pkgs
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

{% if not grains.get('ipv6', 1) %}

disable_ipv6_accept_ra:
  sysctl.present:
    - name: net.ipv6.conf.default.accept_ra
    - value: 0

{# disable/enable is just a trick make accept_ra work #}
disable_ipv6_all:
  sysctl.present:
    - name: net.ipv6.conf.all.disable_ipv6
    - value: 1

enable_ipv6_all:
  sysctl.present:
    - name: net.ipv6.conf.all.disable_ipv6
    - value: 0

{% else % }

enable_ipv6_accept_ra:
  sysctl.present:
    - name: net.ipv6.conf.default.accept_ra
    - value: 1

{# disable/enable is just a trick make accept_ra work #}
disable_ipv6_all:
  sysctl.present:
    - name: net.ipv6.conf.all.disable_ipv6
    - value: 1

enable_ipv6_all:
  sysctl.present:
    - name: net.ipv6.conf.all.disable_ipv6
    - value: 0

{% endif %}

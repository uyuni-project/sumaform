include:
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  - default.network
  - default.firewall
  {% if 'build_image' not in grains.get('product_version', '') and 'paygo' not in grains.get('product_version', '') %}
  - repos
  {% else %}
  - repos.testsuite
  {% endif %}
  - default.avahi
  - default.time

minimal_package_update:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] in ['SLE Micro', 'SL-Micro', 'openSUSE Leap Micro'] %}
  cmd.run:
{% if grains['install_salt_bundle'] %}
    - name: transactional-update -n -c package up zypper libzypp
{% else %}
    - name: transactional-update -n -c package up zypper libzypp salt-minion
{% endif %}
{% else %}
  pkg.latest:
    - pkgs:
{% if grains['install_salt_bundle'] %}
      - venv-salt-minion
{% else %}
      - salt-minion
{% endif %}
# WORKAROUND: don't update zypper and libzypp for opensuse leap 15.5 because the last zypper version is broken
{% if grains['os_family'] == 'Suse' and grains['oscodename'] != 'openSUSE Leap 15.5' %}
      - zypper
      - libzypp
      # WORKAROUND: avoid a segfault on old versions
      {% if '12' in grains['osrelease'] %}
      - libgio-2_0-0
      {% endif %}
{% endif %}
    - order: last
{% endif %}

fixed_minion_version:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] in ['SLE Micro', 'SL-Micro', 'openSUSE Leap Micro'] %}
  cmd.run:
    - name: transactional-update -n -c pkg install venv-salt-minion-3006.0-150000.3.62.2
    - require:
      - cmd: minimal_package_update
{% else %}
  pkg.installed:
{% if grains['os_family'] == 'Debian' %}
    - name: venv-salt-minion
    - version: 3006.0-2.51.1
{% elif grains['os_family'] == 'RedHat' %}
    - name: venv-salt-minion
    - version: 3006.0-1.59.1
{% else %}
    - name: venv-salt-minion
    - version: 3006.0-150000.3.62.2
{% endif %}
    - require:
      - pkg: minimal_package_update
{% endif %}


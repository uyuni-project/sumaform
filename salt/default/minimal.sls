include:
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  - default.network
  - default.firewall
  {% if 'build_image' not in grains.get('product_version', '') and 'paygo' not in grains.get('product_version', '') %}
  - repos
  - scc
  - default.avahi
  {% else %}
  - repos.testsuite
  {% endif %}
  - default.time

minimal_package_update:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] in ['SLE Micro', 'SL-Micro', 'openSUSE Leap Micro'] %}
  cmd.run:
{% if grains['install_salt_bundle'] %}
    - name: transactional-update -n -c package up zypper libzypp venv-salt-minion
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
{% if grains['os_family'] == 'Suse' %}
      - zypper
      - libzypp
      # WORKAROUND: avoid a segfault on old versions
      {% if '12' in grains['osrelease'] %}
      - libgio-2_0-0
      {% endif %}
{% endif %}
    - order: last
{% endif %}

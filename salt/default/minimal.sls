include:
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  - default.network
  - default.firewall
  - default.avahi
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  - default.time

minimal_package_update:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] == 'SLE Micro'  %}
  cmd.run:
{% if grains['install_salt_bundle'] %}
    - name: transactional-update -c package up zypper libzypp venv-salt-minion
{% else %}
    - name: transactional-update -c package up zypper libzypp salt-minion
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

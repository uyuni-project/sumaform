include:
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  - default.network
  - default.firewall
  - default.avahi
  - default.time
  - repos

minimal_package_update:
  pkg.latest:
    - pkgs:
{% if grains.get('product_version', 'default') != 'suma41' %}
      - salt-minion
{% endif %}
{% if grains['os_family'] == 'Suse' %}
      - zypper
      - libzypp
      # HACK: avoid a segfault on old versions
      {% if '12' in grains['osrelease'] %}
      - libgio-2_0-0
      {% endif %}
{% endif %}
    - order: last

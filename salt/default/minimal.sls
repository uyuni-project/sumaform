include:
  - repos
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  - default.network
  - default.avahi

minimal_package_update:
  pkg.latest:
    - pkgs:
      - salt-minion
{% if grains['os_family'] == 'Suse' %}
      - zypper
      - libzypp
      # HACK: avoid a segfault on old versions
      {% if '12' in grains['osrelease'] %}
      - libgio-2_0-0
      {% endif %}
{% endif %}
    - order: last

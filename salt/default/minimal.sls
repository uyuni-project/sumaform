include:
  - repos
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  - default.avahi

minimal_package_update:
  pkg.latest:
    - pkgs:
      - salt-minion
{% if grains['os_family'] == 'Suse' %}
      - zypper
      - libzypp
{% endif %}
    - order: last

include:
  - repos
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  {% if grains['use_avahi'] %}
  - default.avahi
  {% endif %}
  {% if grains['private_network'] %}
  - default.private_network
  {% endif %}

minimal_package_update:
  pkg.latest:
    - pkgs:
      - salt
      - salt-minion
{% if grains['os_family'] == 'Suse' %}
      - zypper
      - libzypp
{% endif %}
    - order: last

include:
  - repos
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  {% if grains['use_avahi'] %}
  - default.avahi
  {% endif %}

minimal_package_update:
  pkg.latest:
    - pkgs:
{%- if grains['os_family'] == 'Debian' %}
      - salt-common
{% else %}
      - salt
{% endif %}
      - salt-minion
{% if grains['os_family'] == 'Suse' %}
      - zypper
      - libzypp
{% endif %}
    - order: last

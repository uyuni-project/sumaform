{% if grains.get('retail') | default(false, true) %}

# NOTE: this is a temporary hack
# it wil go away once we can have proxy running as minion

retail_packages:
  pkg.installed:
    - pkgs:
      - SuSEfirewall2
      - dhcp-server
      - bind

{% endif %}

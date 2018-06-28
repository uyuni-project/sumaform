{% if grains.get('retail') | default(false, true) %}

# NOTE: this is a temporary hack
# it will go away once we can have proxy running as minion

retail_packages:
  pkg.installed:
    - pkgs:
      - branch-network-formula
      - image-sync-formula

{% endif %}

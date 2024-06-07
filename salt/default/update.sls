{% if grains.get('use_os_released_updates') | default(false, true) %}
{% if not grains['osfullname'] in ['SLE Micro', 'SL-Micro'] %}
update_packages:
  pkg.uptodate:
    - require:
      - sls: repos
{% endif %}
{% endif %}

{% if 'additional_packages' in grains %}
install_additional_packages:
  pkg.latest:
    - require:
      - sls: default.repos
    - pkgs:
{% for pkg in grains['additional_packages'] %}
      - {{pkg}}
{% endfor %}
{% endif %}

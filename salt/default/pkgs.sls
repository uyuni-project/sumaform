{% if 'extra_pkgs' in grains %}
install_extra_packages:
  pkg.latest:
    - require:
      - sls: default.repos
    - pkgs:
{% for pkg in grains['extra_pkgs'] %}
      - {{pkg}}
{% endfor %}
{% endif %}

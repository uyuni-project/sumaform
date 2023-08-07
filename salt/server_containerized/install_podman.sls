include:
  - server_containerized.install_common

podman_packages:
  pkg.installed:
    - pkgs:
      - podman
      - netavark
    - require:
      {% if 'build_image' not in grains.get('product_version') | default('', true) %}
      - sls: repos
      {% endif %}

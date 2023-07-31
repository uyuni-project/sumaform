include:
  - server_containerized.install_common

podman_package:
  pkg.installed:
    - name: podman
    - require:
      {% if 'build_image' not in grains.get('product_version') | default('', true) %}
      - sls: repos
      {% endif %}

{% set runtime = grains.get('container_runtime') | default('podman', true) %}
include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  - server_containerized.install_{{ runtime }}
  - server_containerized.additional_disks
  {% if runtime == 'podman' %}
  - server_containerized.install_mgradm
  {% elif runtime == 'rke2' %}
  - server_containerized.install_kubernetes
  {% endif %}
  - server_containerized.initial_content
  - server_containerized.rhn
  - server_containerized.large_deployment
  - server_containerized.testsuite

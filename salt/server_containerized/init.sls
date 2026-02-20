{% set runtime = grains.get('container_runtime') | default('podman', true) %}
include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  {% if runtime == 'podman' %}
  - server_containerized.install_podman
  - server_containerized.additional_disks
  - server_containerized.install_mgradm
  # These following states will be applied for rke2 once we have the basics
  - server_containerized.initial_content
  - server_containerized.rhn
  - server_containerized.large_deployment
  - server_containerized.testsuite
  {% elif runtime == 'rke2' %}
  - kubernetes.install_rke2
  - kubernetes.install_helm
  - kubernetes.set_up_local-path-provisioner
  - server_containerized.install_kubernetes_server
  {% endif %}

{% set runtime = grains.get('container_runtime') | default('podman', true) %}
include:
  - repos
  - server_containerized.install_{{ runtime }}
  - server_containerized.additional_disks
  - server_containerized.install_mgradm
  - server_containerized.hub_peripheral_certs
  - server_containerized.hub_peripheral
  {% if not grains.get('skip_server_install') | default(false, true) %}
  - server_containerized.db_config
  - server_containerized.initial_content
  - server_containerized.rhn
  - server_containerized.large_deployment
  - server_containerized.postgres
  {% endif %}
  - server_containerized.testsuite

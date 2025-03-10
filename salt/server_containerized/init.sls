include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  {% if 'paygo' in grains.get('product_version', '') %}
  - server_containerized.payg_additional_disks
  {% else %}
  - server_containerized.additional_disks
  {% endif %}
  - server_containerized.install_mgradm
  - server_containerized.initial_content
  - server_containerized.testsuite
  - server_containerized.large_deployment

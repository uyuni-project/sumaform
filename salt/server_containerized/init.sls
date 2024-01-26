include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  - server_containerized.additional_disks

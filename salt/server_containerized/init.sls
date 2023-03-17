include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  #- server.salt_master #required by sumaform monitoring
  - server_containerized.install_{{ grains.get('container_runtime') | default('podman', true) }}
  - server_containerized.initial_content


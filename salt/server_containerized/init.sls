include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  #- server.salt_master #required by sumaform monitoring
  - server_containerized.install
  - server_containerized.initial_content


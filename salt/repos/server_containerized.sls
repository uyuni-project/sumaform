{% if 'server_containerized' in grains.get('roles') %}

include:
  {% if '5.0' in grains.get('product_version') %}
  - repos.server_containerized50
  {% elif '5.1' in grains.get('product_version') %}
  - repos.server_containerized51
  {%- elif 'head' in grains['product_version'] %}
  - repos.server_containerizedMain
  {%- else %}
  - repos.server_containerizedUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

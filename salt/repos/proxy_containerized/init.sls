{% if 'proxy_containerized' in grains.get('roles') %}

include:
  {% if '5.0' in grains.get('product_version') %}
  - repos.proxy_containerized.proxy_containerized50
  {% elif '5.1' in grains.get('product_version') %}
  - repos.proxy_containerized.proxy_containerized51
  {% elif '5.2' in grains.get('product_version') %}
  - repos.proxy_containerized.proxy_containerized52
  {%- elif 'head' in grains['product_version'] %}
  - repos.proxy_containerized.proxy_containerizedMain
  {%- else %}
  - repos.proxy_containerized.proxy_containerizedUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

{% if 'proxy_containerized' in grains.get('roles') %}

include:
  {% if '5.0' in grains.get('product_version') %}
  - repos.proxy_containerized50
  {%- elif 'head' in grains['product_version'] %}
  - repos.proxy_containerizedHead
  {%- else %}
  - repos.proxy_containerizedUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

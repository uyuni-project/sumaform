{% if 'proxy' in grains.get('roles') %}
include:
  {%- if '4.2' in grains['product_version'] %}
  - repos.proxy42
  {%- elif '4.3' in grains['product_version'] %}
  - repos.proxy43
  {%- elif 'head' in grains['product_version'] %}
  - repos.proxyHead
  {%- else %}
  - repos.proxyUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

{% if 'server' in grains.get('roles') %}

include:
  {%- if '4.2' in grains['product_version'] %}
  - repos.server42
  {%- elif '4.3' in grains['product_version'] %}
  - repos.server43
  {%- elif 'head' in grains['product_version'] %}
  - repos.serverHead
  {%- else %}
  - repos.serverUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

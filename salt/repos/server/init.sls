{% if 'server' in grains.get('roles') %}

include:
  {%- if '4.2' in grains['product_version'] %}
  - .suma42
  {%- elif '4.3' in grains['product_version'] %}
  - .suma43
  {%- elif 'head' in grains['product_version'] %}
  - .head
  {%- elif 'uyuni' in grains['product_version'] %}
  - .uyuni
  {%- endif %}

{% elif 'server_containerized' in grains.get('roles') and 'uyuni' in grains['product_version'] %}

include:
  - .containerized_uyuni

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

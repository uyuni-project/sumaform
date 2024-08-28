{% if 'proxy_containerized' in grains.get('roles') %}

{%- if 'uyuni' in grains.get('product_version', 'uyuni-master') %}
include:
  - repos.proxy_containerizedUyuni
{% elif '5.0' in grains.get('product_version') %}
include:
  - repos.proxy50
{%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

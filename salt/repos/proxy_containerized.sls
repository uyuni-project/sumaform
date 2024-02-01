{% if 'proxy_containerized' in grains.get('roles') %}

{%- if 'uyuni' in grains.get('product_version', 'uyuni-master') %}
include:
  - repos.proxy_containerizedUyuni
{%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

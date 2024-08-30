{% if 'proxy' in grains.get('roles') or 'proxy_containerized' in grains.get('roles') %}
include:
  {%- if '4.2' in grains['product_version'] %}
  - repos.proxy42
  {%- elif '4.3' in grains['product_version'] %}
  - repos.proxy43
  {% elif 'proxy_containerized' in grains.get('roles') %}
  - repos.proxy_containerized
  {%- else %}
  # We support both flavours of Uyuni Proxy (RPM and containerized)
  - repos.proxyUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

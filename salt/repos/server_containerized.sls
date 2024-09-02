{% if 'server_containerized' in grains.get('roles') %}

{%- if 'uyuni' in grains.get('product_version', 'uyuni-master') %}
include:
  - repos.server_containerizedUyuni
{% elif '5.0' in grains.get('product_version') %}
# we already include this with cloud-init for SLE Micro 5.5
# include:
#  - repos.server50
{%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

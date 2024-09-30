include:
  - scc

{% if grains['additional_packages'] %}
install_additional_packages:
  {% if grains['os_family'] == 'Suse' and grains['osfullname'] in ['SLE Micro', 'SL-Micro'] %}
  cmd.run:
{% for package in grains['additional_packages'] %}
    - name: transactional-update -c -n pkg in {{ package }}
{% endfor %}
  {% else %}
  pkg.latest:
    - pkgs:
{% for package in grains['additional_packages'] %}
      - {{ package }}
{% endfor %}
  {% endif %}
    {% if 'paygo' not in grains.get('product_version', '') %}
    - require:
      - sls: repos
      {% if grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code') %}
      - sls: scc
      {% endif %}
    {% endif %}
{% endif %}

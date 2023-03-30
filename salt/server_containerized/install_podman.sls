server_packages:
  pkg.installed:
    - refresh: True
    - name: uyuni-server-systemd-services
    - require:
      {% if 'build_image' not in grains.get('product_version') | default('', true) %}
      - sls: repos
      {% endif %}

{% if grains.get("container_repository") -%}
uyuni-server-services_config:
  file.replace:
    - name: /etc/sysconfig/uyuni-server-systemd-services
    - pattern: ^NAMESPACE=/.*$
    - repl: NAMESPACE={{ grains.get("container_repository") }}
    - append_if_not_found: True
{%- endif %}

uyuni-server_service:
  service.running:
    - name: uyuni-server
    - enable: True
    - require:
      - pkg: uyuni-server-systemd-services
{% if grains.get("container_repository") %}
      - file: uyuni-server-services_config
    - watch:
      - file: uyuni-server-services_config
{% endif %}

wait_for_setup_end:
  cmd.script:
    - name: salt://server_containerized/wait_for_setup_end.py
    - args: {{ grains.get('container_runtime') }}
    - use_vt: True
    - template: jinja
    - require:
      - service: uyuni-server_service


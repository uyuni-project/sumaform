include:
  - server_containerized.install_common

server_packages:
  pkg.installed:
    - refresh: True
    - name: uyuni-server-systemd-services
    - require:
      {% if 'build_image' not in grains.get('product_version') | default('', true) %}
      - sls: repos
      {% endif %}

uyuni_server_services_config_sccuser:
  file.replace:
    - name: /etc/sysconfig/uyuni-server-systemd-services
    - pattern: ^SCC_USER=.*$
    - repl: SCC_USER="{{ grains.get('cc_username') }}"
    - append_if_not_found: True

uyuni_server_services_config_sccpass:
  file.replace:
    - name: /etc/sysconfig/uyuni-server-systemd-services
    - pattern: ^SCC_PASS=.*$
    - repl: SCC_PASS="{{ grains.get('cc_password') }}"
    - append_if_not_found: True

uyuni_server_services_config_fqdn:
  file.replace:
    - name: /etc/sysconfig/uyuni-server-systemd-services
    - pattern: ^(REPORT_DB_HOST|UYUNI_FQDN)=.*$
    - repl: \1="{{ grains.get('fqdn') }}"
    - append_if_not_found: True

{% if grains.get("java_debugging") %}
uyuni_server_services_config_debug:
  file.replace:
    - name: /etc/sysconfig/uyuni-server-systemd-services
    - pattern: ^EXTRA_POD_ARGS='([^']*)'$
    - repl: EXTRA_POD_ARGS='-p 8000:8000 -p 8001:8001 \1'
    - append_if_not_found: True
{% endif %}

{% if grains.get("container_repository") -%}
uyuni-server-services_config:
  file.replace:
    - name: /etc/sysconfig/uyuni-server-systemd-services
    - pattern: ^NAMESPACE=.*$
    - repl: NAMESPACE="{{ grains.get('container_repository') }}"
    - append_if_not_found: True
{%- endif %}

{%- set mirror_hostname = grains.get('server_mounted_mirror') if grains.get('server_mounted_mirror') else grains.get('mirror') %}
{% if mirror_hostname -%}
uyuni_server_services_config_mirror:
  file.replace:
    - name: /etc/sysconfig/uyuni-server-systemd-services
    - pattern: ^EXTRA_POD_ARGS='([^']*)'$
    - repl: EXTRA_POD_ARGS='-v=/srv/mirror:/mirror -e MIRROR_PATH=/mirror \1'
    - append_if_not_found: True
{%- endif %}

uyuni-server_service:
  service.running:
    - name: uyuni-server
    - enable: True
    - require:
      - pkg: uyuni-server-systemd-services
      - sls: server_containerized.install_common
      - file: uyuni_server_services_config_sccuser
      - file: uyuni_server_services_config_sccpass
      - file: uyuni_server_services_config_fqdn
{% if grains.get("java_debugging") %}
      - file: uyuni_server_services_config_debug
{% endif %}
{% if mirror_hostname %}
      - file: uyuni_server_services_config_mirror
{% endif %}
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


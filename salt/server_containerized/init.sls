include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}

server_packages:
  pkg.installed:
    - refresh: True
    - name: uyuni-server-systemd-services

environment_setup_script:
  file.managed:
    - name: /root/setup_env.sh
    - source: salt://server/setup_env.sh
    - template: jinja

uyuni-server_service:
  file.managed: server-systemd-services/uyuni-server.service
  #TODO it should be installed by default. In case of any changes, add the file here
  #    - source:

uyuni-server-services_config:
  file.managed:
    - name: /etc/sysconfig/container-server-services.config
    - makedir: True
  #TODO it should be installed by default. In case of any changes, add the file here
  #    - source:

service.running:
  - name: uyuni-server
  - enable: True
  - require:
    - file: postgres_exporter_service
    - file: environment_setup_script
    - pkg: uyuni-server-systemd-services
  - watch:
    - file: uyuni-server-services_config

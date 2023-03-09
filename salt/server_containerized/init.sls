include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  #- server.salt_master #required by sumaform monitoring

server_packages:
  pkg.installed:
    - refresh: True
    - name: uyuni-server-systemd-services
    - require:
      {% if 'build_image' not in grains.get('product_version') | default('', true) %}
      - sls: repos
      {% endif %}

uyuni-server_service_file:
  file.managed: 
    - name: /usr/lib/systemd/system/uyuni-server.service
    - makedir: True

uyuni-server-services_config:
  file.managed:
    - name: /etc/sysconfig/container-server-services.config
    - makedir: True
  #TODO it should be installed by default. In case of any changes, add the file here
  #    - source:

uyuni-server_service:
  service.running:
    - name: uyuni-server
    - enable: True
    - require:
      - file: uyuni-server_service_file
      - file: uyuni-server-services_config
      - pkg: uyuni-server-systemd-services
    - watch:
      - file: uyuni-server-services_config

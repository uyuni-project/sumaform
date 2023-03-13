server_packages:
  pkg.installed:
    - refresh: True
    - name: uyuni-server-systemd-services
    - require:
      {% if 'build_image' not in grains.get('product_version') | default('', true) %}
      - sls: repos
      {% endif %}

uyuni-server-services_config:
  file.managed:
    - name: /etc/sysconfig/uyuni-server-systemd-services
    - makedir: True
  #TODO it should be installed by default. In case of any changes, add the file here
  #    - source:

uyuni-server_service:
  service.running:
    - name: uyuni-server
    - enable: True
    - require:
      - file: uyuni-server-services_config
      - pkg: uyuni-server-systemd-services
    - watch:
      - file: uyuni-server-services_config

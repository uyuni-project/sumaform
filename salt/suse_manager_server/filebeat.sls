{% if grains.get('log_server') | default(false, true) %}

include:
  - repos
  - suse_manager_server

filebeat:
  pkg.installed:
    - name: filebeat
    - require:
      - sls: suse_manager_server

filebeat_configuration:
  file.managed:
    - name: /etc/filebeat/filebeat.yml
    - source: salt://suse_manager_server/filebeat.yml
    - template: jinja
    - makedirs: True

service:
  service.running:
    - name: filebeat
    - watch:
      - file: filebeat_configuration
    - require:
      - pkg: filebeat
      - file: filebeat_configuration

{% endif %}

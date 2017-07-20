{% if grains.get('filebeat', false) %}

include:
  - default
  - suse_manager_server

refresh_filebeat_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: filebeat_repo

filebeat:
  pkg.installed:
    - name: filebeat
    - require:
      - sls: suse_manager_server
      - cmd: refresh_filebeat_repos

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

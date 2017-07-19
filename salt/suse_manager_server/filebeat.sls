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

# inject filebeat.yml
/etc/filebeat/filebeat.yml:
  file.managed:
    - source: salt://suse_manager_server/filebeat.yml
    - makedirs: True

service:
  service.running:
    - name: filebeat
    - watch:
      - file: /etc/filebeat/filebeat.yml
    - require:
      - pkg: filebeat
      - file: /etc/filebeat/filebeat.yml

{% endif %}

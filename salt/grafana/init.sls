include:
  - repos

prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
    - require:
      - sls: repos

prometheus_configuration:
  file.recurse:
    - name: /etc/prometheus/
    - source: salt://grafana/prometheus
    - template: jinja
    - include_empty: True

prometheus_service:
  service.running:
    - name: prometheus
    - enable: True
    - reload: True
    - require:
      - pkg: prometheus-suma_sd
      {% if grains['monitor_alert_email'] %}
      - pkg: prometheus-alertmanager
      {% endif %}
      - file: prometheus_configuration
    - watch:
      - file: prometheus_configuration

prometheus-node_exporter:
  pkg.installed:
    - names:
      - golang-github-prometheus-node_exporter
  service.running:
    - enable: True

prometheus-suma_sd:
  pkg.installed:
    - names:
      - golang-github-cavalheiro-prometheus-suma_sd
  service.running:
    - enable: True
    - reload: True
    - require:
      - file: prometheus_configuration
    - watch:
      - file: prometheus_configuration

{% if grains['monitor_alert_email'] %}
prometheus-alertmanager:
  pkg.installed:
    - names:
      - golang-github-prometheus-alertmanager
    - enable: True
    - reload: True
    - require:
      - file: prometheus_configuration
    - watch:
      - file: prometheus_configuration
{% endif %}

grafana:
  pkg.installed:
    - name: grafana
    - require:
      - sls: repos

grafana_anonymous_login_configuration:
  file.blockreplace:
    - name: /etc/grafana/grafana.ini
    - marker_start: '#################################### Anonymous Auth ######################'
    - marker_end: '#################################### Github Auth ##########################'
    - content: |
        [auth.anonymous]
        enabled = true
        org_name = Main Org.
        org_role = Admin
    - require:
      - pkg: grafana

grafana_port_configuration:
  file.replace:
    - name: /etc/grafana/grafana.ini
    - pattern: ;http_port = 3000
    - repl: http_port = 80
    - require:
      - pkg: grafana

grafana_provisioning_directory:
  file.recurse:
    - name: /etc/grafana/provisioning
    - source: salt://grafana/provisioning
  {% if not grains["monitor_systems"] %}
    - exclude_pat: E@(client-systems.json)|(dashboard-provider.yml)
  {% endif %}
    - clean: True
    - user: grafana
    - group: grafana
    - require:
      - pkg: grafana

grafana_service_configuration:
  file.replace:
    - name: /usr/lib/systemd/system/grafana-server.service
    - pattern: (User|Group)=grafana
    - repl: '#\1'
    - require:
      - pkg: grafana

grafana_service:
  service.running:
    - name: grafana-server
    - enable: True
    - restart: True
    - require:
      - pkg: grafana
      - file: grafana_port_configuration
      - file: grafana_provisioning_directory
      - file: grafana_service_configuration
    - watch:
      - file: grafana_port_configuration
      - file: grafana_provisioning_directory
      - file: grafana_service_configuration

grafana_setup:
  cmd.script:
    - name: salt://grafana/setup_grafana.py
    - require:
      - service: grafana_service

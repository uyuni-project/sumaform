include:
  - repos

prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
    - version: 1.5.2
    - require:
      - sls: repos

prometheus_configuration:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - makedirs: True
    - contents: |
        scrape_configs:
          - job_name: 'sumaform'
            scrape_interval: 5s
            static_configs:
              - targets: ['{{grains["server"]}}:9100'] # node_exporter
              - targets: ['{{grains["server"]}}:9187'] # postgres_exporter
              - targets: ['{{grains["server"]}}:5556'] # jmx_exporter
              - targets: ['{{grains["server"]}}:5557'] # jmx_exporter taskomatic
              {% if grains.get("locust") %}
              - targets: ['{{grains["locust"]}}:9500'] # locust_exporter
              {% endif %}
          - job_name: 'tomcat'
            scrape_interval: 5s
            metrics_path: /rhn/metrics
            static_configs:
              - targets: ['{{grains["server"]}}:80']
          - job_name: 'taskomatic'
            scrape_interval: 5s
            static_configs:
              - targets: ['{{grains["server"]}}:9800']

prometheus_service:
  file.managed:
    - name: /etc/systemd/system/prometheus.service
    - contents: |
        [Unit]
        Description=prometheus

        [Service]
        ExecStart=/usr/bin/prometheus --config.file=/etc/prometheus/prometheus.yml

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: prometheus
  service.running:
    - name: prometheus
    - enable: True
    - require:
      - file: prometheus_service
      - file: prometheus_configuration
    - watch:
      - file: prometheus_configuration

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
    - template: jinja
    - require:
      - service: grafana_service

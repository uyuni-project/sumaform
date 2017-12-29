include:
  - repos

prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
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
              {% if grains["locust"] %}
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
        ExecStart=/usr/bin/prometheus -config.file=/etc/prometheus/prometheus.yml

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
  archive.extracted:
    - name: /opt/grafana
    {% if grains.get('mirror') %}
    - source: http://{{grains.get("mirror")}}/grafana-5.2.2.linux-amd64.tar.gz
    {% else %}
    - source: https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.2.2.linux-amd64.tar.gz
    {% endif %}
    - source_hash: sha256=74ecb544787d37a2f743faa2f2304ca11e37438c32ce5b13e07a70ae47982bbb
    - archive_format: tar
    - options: --strip-components=1
    - enforce_toplevel: False
    - keep: True
    - if_missing: /opt/grafana

grafana_configuration_file:
  file.replace:
    - name: /opt/grafana/conf/sample.ini
    - pattern: ;http_port = 3000
    - repl: http_port = 80
    - require:
      - archive: grafana

grafana_service:
  file.managed:
    - name: /etc/systemd/system/grafana.service
    - contents: |
        [Unit]
        Description=grafana

        [Service]
        ExecStart=/opt/grafana/bin/grafana-server -homepath=/opt/grafana -config=/opt/grafana/conf/sample.ini

        [Install]
        WantedBy=multi-user.target
    - require:
      - archive: grafana
      - file: grafana_configuration_file
  service.running:
    - name: grafana
    - enable: True
    - require:
      - file: grafana_service

suse_manager_dashboard:
  file.managed:
    - name: /opt/grafana/conf/suse_manager.json
    - source: salt://grafana/dashboards/suse_manager.json
    - require:
      - archive: grafana

grafana_configuration:
  cmd.script:
    - name: salt://grafana/setup_grafana.py
    - require:
      - service: grafana
      - file: suse_manager_dashboard

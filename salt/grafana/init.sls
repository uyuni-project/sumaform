tools_repo:
  file.managed:
    - name: /etc/zypp/repos.d/home_SilvioMoioli_tools.repo
    - source: salt://grafana/repos.d/home_SilvioMoioli_tools.repo
    - template: jinja
    - require:
      - sls: default

refresh_grafana_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: tools_repo

prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
    - require:
      - cmd: refresh_grafana_repos

prometheus_configuration:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - makedirs: True
    - contents: |
        global:
          scrape_interval: 5s
        scrape_configs:
          - job_name: 'suse_manager_server'
            static_configs:
              - targets: ['{{grains["server"]}}:9100'] # node_exporter
              - targets: ['{{grains["server"]}}:9187'] # postgres_exporter
              - targets: ['{{grains["server"]}}:5556'] # jmx_exporter
              {% if grains["locust"] %}
              - targets: ['{{grains["locust"]}}:9500'] # locust_exporter
              {% endif %}

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
    - source: http://{{grains.get("mirror")}}/grafana-4.2.0.linux-x64.tar.gz
    {% else %}
    - source: https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.2.0.linux-x64.tar.gz
    {% endif %}
    - source_hash: sha256=e9927baaaf6cbcab64892dedd11ccf509e4edea54670db4250b9e7568466ec61
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

grafana_dashboard_dump_file:
  file.managed:
    - name: /opt/grafana/conf/dashboard.json
    - source: salt://grafana/dashboard.json
    - require:
      - archive: grafana

grafana_configuration:
  cmd.script:
    - name: salt://grafana/setup_grafana.py
    - require:
      - service: grafana
      - file: grafana_dashboard_dump_file

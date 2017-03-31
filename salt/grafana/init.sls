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

grafana:
  archive.extracted:
    - name: /opt/grafana
    - source: http://users.suse.com/~smoioli/sumaform-data/grafana-4.2.0.linux-x64.tar.gz
    - source_hash: sha256=e9927baaaf6cbcab64892dedd11ccf509e4edea54670db4250b9e7568466ec61
    - archive_format: tar
    - tar_options: --strip-components=1
    - keep: True
    - if_missing: /opt/grafana

grafana_database:
  file.managed:
    - name: /opt/grafana/data/grafana.db
    - makedirs: True
    - source: salt://grafana/grafana.db
    - replace: False
    - require:
      - archive: grafana

grafana_configuration:
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
      - file: grafana_configuration
      - file: grafana_database
  service.running:
    - name: grafana
    - enable: True
    - require:
      - file: grafana_service

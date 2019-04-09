{% if grains.get('monitored') | default(false, true) %}

include:
  - repos

node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter
    - require:
      - sls: repos

node_exporter_service:
  service.running:
    - name: prometheus-node_exporter
    - enable: True
    - require:
      - pkg: node_exporter

postgres_exporter:
  pkg.installed:
    - name: golang-github-wrouesnel-postgres_exporter
    - require:
      - sls: repos

postgres_exporter_configuration:
  file.managed:
    - name: /etc/prometheus-postgres_exporter/postgres_exporter_queries.yaml
    - makedirs: True
    - contents: |
        mgr_serveractions:
          query: |
            SELECT (
              SELECT COUNT(*)
                FROM rhnServerAction
                WHERE status = (
                  SELECT id FROM rhnActionStatus WHERE name = 'Queued'
               )
            ) AS queued,
            (
              SELECT COUNT(*)
                FROM rhnServerAction
                WHERE status = (
                  SELECT id FROM rhnActionStatus WHERE name = 'Picked Up'
               )
            ) AS picked_up,
            (
              SELECT COUNT(*)
                FROM rhnServerAction
                WHERE status = (
                  SELECT id FROM rhnActionStatus WHERE name IN ('Completed')
               )
            ) AS completed,
            (
              SELECT COUNT(*)
                FROM rhnServerAction
                WHERE status = (
                  SELECT id FROM rhnActionStatus WHERE name IN ('Failed')
               )
            ) AS failed;
          metrics:
            - queued:
                usage: "GAUGE"
                description: "Count of queued Actions"
            - picked_up:
                usage: "GAUGE"
                description: "Count of picked up Actions"
            - completed:
                usage: "COUNTER"
                description: "Count of completed Actions"
            - failed:
                usage: "COUNTER"
                description: "Count of failed Actions"
        salt_events:
          query: |
              SELECT COUNT(*)
                FROM suseSaltEvent
                AS salt_events_count;
          metrics:
            - salt_events_count:
                usage: "GAUGE"
                description: "Count of suse salt events"

postgres_exporter_service:
  file.managed:
    - name: /etc/sysconfig/prometheus-postgres_exporter
    - source: salt://server/postgres-exporter
    - require:
      - pkg: postgres_exporter
      - file: postgres_exporter_configuration
  service.running:
    - name: prometheus-postgres_exporter
    - enable: True
    - require:
      - file: postgres_exporter_service
    - watch:
      - file: postgres_exporter_configuration

jmx_exporter:
  pkg.installed:
    - pkgs:
      - prometheus-jmx_exporter
      - prometheus-jmx_exporter-tomcat
    - require:
      - sls: repos

jmx_exporter_tomcat_service:
  service.running:
    - name: prometheus-jmx_exporter@tomcat
    - enable: True
    - require:
      - pkg: jmx_exporter

jmx_exporter_taskomatic_systemd_config:
  file.managed:
    - name: /etc/prometheus-jmx_exporter/taskomatic/environment
    - makedirs: True
    - contents: |
        PORT="5557"
        EXP_PARAMS=""

jmx_exporter_taskomatic_yaml_config:
  file.managed:
    - name: /etc/prometheus-jmx_exporter/taskomatic/prometheus-jmx_exporter.yml
    - makedirs: True
    - contents: |
        hostPort: localhost:3334
        username:
        password:
        whitelistObjectNames:
          - java.lang:type=Threading,*
          - java.lang:type=Memory,*
          - Catalina:type=ThreadPool,name=*
        rules:
        - pattern: ".*"

jmx_exporter_taskomatic_service:
  service.running:
    - name: prometheus-jmx_exporter@taskomatic
    - enable: True
    - require:
      - pkg: jmx_exporter
      - file: jmx_exporter_taskomatic_systemd_config
      - file: jmx_exporter_taskomatic_yaml_config

{% endif %}

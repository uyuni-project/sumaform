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
{% if 'head' not in grains['product_version'] %}
    - version: '<0.4.7'
{% endif %}
    - require:
      - sls: repos

postgres_exporter_configuration:
  file.managed:
    - name: /etc/postgres_exporter/postgres_exporter_queries.yaml
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

postgres_exporter_service:
  file.managed:
{% if 'head' in grains['product_version'] %}
    - name: /etc/sysconfig/prometheus-postgres_exporter
{% else %}
    - name: /etc/sysconfig/postgres-exporter
{% endif %}
    - source: salt://suse_manager_server/postgres-exporter
    - require:
      - pkg: postgres_exporter
      - file: postgres_exporter_configuration
  service.running:
{% if 'head' in grains['product_version'] %}
    - name: prometheus-postgres_exporter
{% else %}
    - name: postgres-exporter
{% endif %}
    - enable: True
    - require:
      - file: postgres_exporter_service
    - watch:
      - file: postgres_exporter_configuration

jmx_exporter:
  pkg.installed:
    - pkgs:
{% if 'head' in grains['product_version'] %}
      - prometheus-jmx_exporter
      - prometheus-jmx_exporter-tomcat
{% else %}
      - jmx_exporter
      - jmx_exporter-tomcat
{% endif %}
    - require:
      - sls: repos

jmx_exporter_tomcat_service:
  service.running:
{% if 'head' in grains['product_version'] %}
    - name: prometheus-jmx_exporter@tomcat
{% else %}
    - name: jmx-exporter@tomcat
{% endif %}
    - enable: True
    - require:
      - pkg: jmx_exporter

jmx_exporter_taskomatic_systemd_config:
  file.managed:
    - name: /etc/jmx_exporter/taskomatic/environment
    - makedirs: True
    - contents: |
        PORT="5557"
        EXP_PARAMS=""

jmx_exporter_taskomatic_yaml_config:
  file.managed:
    - name: /etc/jmx_exporter/taskomatic/jmx_exporter.yml
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
{% if 'head' in grains['product_version'] %}
    - name: prometheus-jmx_exporter@taskomatic
{% else %}
    - name: jmx-exporter@taskomatic
{% endif %}
    - enable: True
    - require:
      - pkg: jmx_exporter
      - file: jmx_exporter_taskomatic_systemd_config
      - file: jmx_exporter_taskomatic_yaml_config

{% endif %}

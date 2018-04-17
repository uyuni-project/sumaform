{% if grains.get('monitored') | default(false, true) %}

include:
  - suse_manager_server

prometheus_repo:
  file.managed:
    - name: /etc/zypp/repos.d/systemsmanagement-sumaform-tools.repo
    - source: salt://default/repos.d/systemsmanagement-sumaform-tools.repo
    - template: jinja
    - require:
      - sls: suse_manager_server

refresh_prometheus_repo:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: prometheus_repo

node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter
    - require:
      - sls: suse_manager_server
      - cmd: refresh_prometheus_repo

node_exporter_service:
  file.managed:
    - name: /etc/systemd/system/node-exporter.service
    - contents: |
        [Unit]
        Description=node_exporter

        [Service]
        ExecStart=/usr/bin/node_exporter

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: node_exporter
  service.running:
    - name: node-exporter
    - enable: True
    - require:
      - file: node_exporter_service

postgres_exporter:
  pkg.installed:
    - name: golang-github-wrouesnel-postgres_exporter
    - require:
      - sls: suse_manager_server
      - cmd: refresh_prometheus_repo

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
    - name: /etc/systemd/system/postgres-exporter.service
    - contents: |
        [Unit]
        Description=postgres_exporter

        [Service]
        Environment=DATA_SOURCE_NAME=postgresql://spacewalk:spacewalk@localhost:5432/susemanager?sslmode=disable
        ExecStart=/usr/bin/postgres_exporter -extend.query-path /etc/postgres_exporter/postgres_exporter_queries.yaml

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: node_exporter
      - file: postgres_exporter_configuration
  service.running:
    - name: postgres-exporter
    - enable: True
    - require:
      - file: postgres_exporter_service
    - watch:
      - file: postgres_exporter_configuration

jmx_exporter:
  pkg.installed:
    - name: jmx_exporter
    - require:
      - sls: suse_manager_server
      - cmd: refresh_prometheus_repo

tomcat_jmx_exporter_configuration:
  file.managed:
    - name: /etc/jmx_exporter/tomcat_jmx_exporter.yml
    - makedirs: True
    - contents: |
        hostPort: localhost:3333
        username:
        password:
        whitelistObjectNames:
          - java.lang:type=Threading,*
          - java.lang:type=Memory,*
          - Catalina:type=ThreadPool,name=*
        rules:
        - pattern: ".*"

tomcat_jmx_exporter_service:
  file.managed:
    - name: /etc/systemd/system/tomcat-jmx-exporter.service
    - contents: |
        [Unit]
        Description=jmx_exporter

        [Service]
        ExecStart=/usr/bin/java -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=5555 -jar /usr/share/java/jmx_prometheus_httpserver.jar 5556 /etc/jmx_exporter/tomcat_jmx_exporter.yml

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: jmx_exporter
  service.running:
    - name: tomcat-jmx-exporter
    - enable: True
    - require:
      - file: tomcat_jmx_exporter_service
      - file: tomcat_jmx_exporter_configuration

taskomatic_jmx_exporter_configuration:
  file.managed:
    - name: /etc/jmx_exporter/taskomatic_jmx_exporter.yml
    - makedirs: True
    - contents: |
        hostPort: localhost:3334
        username:
        password:
        whitelistObjectNames:
          - quartz:type=QuartzScheduler,*
        rules:
        - pattern: ".*"

taskomatic_jmx_exporter_service:
  file.managed:
    - name: /etc/systemd/system/taskomatic-jmx-exporter.service
    - contents: |
        [Unit]
        Description=jmx_exporter

        [Service]
        ExecStart=/usr/bin/java -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=5557 -jar /usr/share/java/jmx_prometheus_httpserver.jar 5558 /etc/jmx_exporter/taskomatic_jmx_exporter.yml

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: jmx_exporter
  service.running:
    - name: taskomatic-jmx-exporter
    - enable: True
    - require:
      - file: taskomatic_jmx_exporter_service
      - file: taskomatic_jmx_exporter_configuration
{% endif %}

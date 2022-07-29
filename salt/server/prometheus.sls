{% if grains.get('monitored') | default(false, true) %}

node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter
    {% if 'build_image' not in grains.get('product_version') | default('', true) %}
    - require:
      - sls: repos
    {% endif %}

node_exporter_service:
  service.running:
    - name: prometheus-node_exporter
    - enable: True
    - require:
      - pkg: node_exporter

postgres_exporter:
  pkg.installed:
    - name: prometheus-postgres_exporter
    - resolve_capabilities: True
    {% if 'build_image' not in grains.get('product_version') | default('', true) %}
    - require:
      - sls: repos
    {% endif %}

postgres_exporter_configuration:
  file.managed:
    - name: /etc/postgres_exporter/postgres_exporter_queries.yaml
    - makedirs: True
    - source: salt://server/postgres_exporter_queries.yaml

postgres_exporter_service:
  file.managed:
    - name: /etc/sysconfig/prometheus-postgres_exporter
    - source: salt://server/postgres-exporter
    - template: jinja
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
    - name: prometheus-jmx_exporter
    {% if 'build_image' not in grains.get('product_version') | default('', true) %}
    - require:
      - sls: repos
    {% endif %}

jmx_exporter_tomcat_yaml_config:
  file.managed:
    - name: /etc/prometheus-jmx_exporter/tomcat/java_agent.yml
    - makedirs: True
    - source: salt://server/java_agent.yaml

jmx_tomcat_config:
  file.managed:
    - name: /usr/lib/systemd/system/tomcat.service.d/jmx.conf
    - makedirs: True
    - source: salt://server/tomcat_jmx.conf
    - require:
      - pkg: jmx_exporter
  module.run:
    - name: service.systemctl_reload

jmx_exporter_taskomatic_yaml_config:
  file.managed:
    - name: /etc/prometheus-jmx_exporter/taskomatic/java_agent.yml
    - makedirs: True
    - source: salt://server/java_agent.yaml

jmx_taskomatic_config:
  file.managed:
    - name: /usr/lib/systemd/system/taskomatic.service.d/jmx.conf
    - makedirs: True
    - source: salt://server/taskomatic_jmx.conf
    - require:
      - pkg: jmx_exporter
  module.run:
    - name: service.systemctl_reload

{% endif %}

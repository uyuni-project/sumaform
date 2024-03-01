# See https://documentation.suse.com/suma/4.3/en/suse-manager/specialized-guides/large-deployments/tuning.html

{% if grains.get('large_deployment') | default(false, true) %}

include:
  - server_containerized.install_{{ grains.get('container_runtime') | default('podman', true) }}

large_deployment_increase_tasko_parallel_threads:
  cmd.run:
    - name: mgrctl exec 'echo "taskomatic.com.redhat.rhn.taskomatic.task.MinionActionExecutor.parallel_threads = 3" >> /etc/rhn/rhn.conf'
{% if grains['osfullname'] != 'SLE Micro' %}
    - require:
      - pkg: uyuni-tools
{% endif %}

large_deployment_increase_hibernate_max_connections:
  cmd.run:
    - name: mgrctl exec 'echo "hibernate.c3p0.max_size = 50" >> /etc/rhn/rhn.conf'
{% if grains['osfullname'] != 'SLE Micro' %}
    - require:
      - pkg: uyuni-tools
{% endif %}

large_deployment_tune_tomcat_stylesheet_host:
  file.managed:
    - name: /tmp/large_deployment_tune_tomcat.xslt
    - source: salt://server_containerized/large_deployment_tune_tomcat.xslt

large_deployment_tune_tomcat_stylesheet_copy:
  cmd.run:
    - name: mgrctl cp /tmp/large_deployment_tune_tomcat.xslt server:/tmp/large_deployment_tune_tomcat.xslt
    - onchanges:
      - file: large_deployment_tune_tomcat_stylesheet_host

large_deployment_tune_tomcat_maxthreads:
  cmd.run:
    - name: mgrctl exec 'xsltproc /tmp/large_deployment_tune_tomcat.xslt /etc/tomcat/server.xml > /tmp/tomcat_server.xml && mv /tmp/tomcat_server.xml /etc/tomcat/server.xml'
    - onchanges:
      - cmd: large_deployment_tune_tomcat_stylesheet_copy

large_deployment_tomcat_restart:
  cmd.run:
    - name: mgrctl exec systemctl restart tomcat
    - watch:
      - cmd: large_deployment_increase_tasko_parallel_threads
      - cmd: large_deployment_increase_hibernate_max_connections
      - cmd: large_deployment_tune_tomcat_maxthreads

large_deployment_increase_database_max_connections:
  cmd.run:
    - name: mgrctl exec 'sed -i "s/max_connections = (.*)/max_connections = 450/" /var/lib/pgsql/data/postgresql.conf'
{% if grains['osfullname'] != 'SLE Micro' %}
    - require:
      - pkg: uyuni-tools
{% endif %}

large_deployment_increase_database_work_memory:
  cmd.run:
    - name: mgrctl exec 'sed -i "s/work_mem = (.*)/work_mem = 10MB/" /var/lib/pgsql/data/postgresql.conf'
{% if grains['osfullname'] != 'SLE Micro' %}
    - require:
      - pkg: uyuni-tools
{% endif %}

large_deployment_postgresql_restart:
  cmd.run:
    - name: mgrctl exec systemctl restart postgresql
    - watch:
      - cmd: large_deployment_increase_database_max_connections
      - cmd: large_deployment_increase_database_work_memory

{% endif %}

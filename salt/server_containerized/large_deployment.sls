# See https://documentation.suse.com/suma/4.3/en/suse-manager/specialized-guides/large-deployments/tuning.html

{% if grains.get('large_deployment') | default(false, true) %}

large_deployment_increase_tasko_parallel_threads:
  cmd.run:
    - name: mgrctl exec 'echo "taskomatic.com.redhat.rhn.taskomatic.task.MinionActionExecutor.parallel_threads = 3" >> /etc/rhn/rhn.conf'

large_deployment_increase_hibernate_max_connections:
  cmd.run:
    - name: mgrctl exec 'echo "hibernate.c3p0.max_size = 100" >> /etc/rhn/rhn.conf'

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

{% if 'uyuni-master' in grains.get('product_version', '') or 'uyuni-pr' in grains.get('product_version', '') or 'head' in grains.get('product_version', '') %}
large_deployment_increase_database_max_connections_db_container:
  cmd.run:
    - name: podman exec uyuni-db sed -i "s/max_connections = .*/max_connections = 400/" /var/lib/pgsql/data/postgresql.conf

large_deployment_increase_database_work_memory_db_container:
  cmd.run:
    - name: podman exec uyuni-db sed -i "s/work_mem = .*/work_mem = 20MB/" /var/lib/pgsql/data/postgresql.conf

large_deployment_postgresql_restart_db_container:
  cmd.run:
    - name: podman restart uyuni-db
    - watch:
      - cmd: large_deployment_increase_database_max_connections_db_container
      - cmd: large_deployment_increase_database_work_memory_db_container
{% else %}
large_deployment_increase_database_max_connections:
  cmd.run:
    - name: mgrctl exec 'sed -i "s/max_connections = (.*)/max_connections = 400/" /var/lib/pgsql/data/postgresql.conf'

large_deployment_increase_database_work_memory:
  cmd.run:
    - name: mgrctl exec 'sed -i "s/work_mem = (.*)/work_mem = 20MB/" /var/lib/pgsql/data/postgresql.conf'

large_deployment_postgresql_restart:
  cmd.run:
    - name: mgrctl exec systemctl restart postgresql
    - watch:
      - cmd: large_deployment_increase_database_max_connections
      - cmd: large_deployment_increase_database_work_memory
{% endif %}
{% endif %}

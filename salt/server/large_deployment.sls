# See https://documentation.suse.com/suma/4.3/en/suse-manager/specialized-guides/large-deployments/tuning.html

{% if grains.get('large_deployment') | default(false, true) %}

include:
  - server

large_deployment_increase_tasko_parallel_threads:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: 'taskomatic.com.redhat.rhn.taskomatic.task.MinionActionExecutor.parallel_threads = (.*)'
    - repl: 'taskomatic.com.redhat.rhn.taskomatic.task.MinionActionExecutor.parallel_threads = 3'
    - append_if_not_found: True
    - require:
      - cmd: server_setup

large_deployment_increase_hibernate_max_connections:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: 'hibernate.c3p0.max_size = (.*)'
    - repl: 'hibernate.c3p0.max_size = 50'
    - append_if_not_found: True
    - require:
      - cmd: server_setup

large_deployment_tune_tomcat_stylesheet:
  file.managed:
    - name: /tmp/large_deployment_tune_tomcat.xslt
    - source: salt://server/large_deployment_tune_tomcat.xslt

large_deployment_tune_tomcat_maxthreads:
  cmd.run:
    - name: xsltproc /tmp/large_deployment_tune_tomcat.xslt /etc/tomcat/server.xml > /tmp/tomcat_server.xml && mv /tmp/tomcat_server.xml /etc/tomcat/server.xml
    - require:
      - cmd: server_setup
      - file: large_deployment_tune_tomcat_stylesheet

large_deployment_tomcat:
  service.running:
    - name: tomcat
    - watch:
      - file: large_deployment_increase_tasko_parallel_threads
      - file: large_deployment_increase_hibernate_max_connections
      - cmd: large_deployment_tune_tomcat_maxthreads

large_deployment_increase_database_max_connections:
  file.replace:
    - name: /var/lib/pgsql/data/postgresql.conf
    - pattern: 'max_connections = (.*)'
    - repl: 'max_connections = 450'
    - append_if_not_found: True
    - require:
      - cmd: server_setup

large_deployment_increase_database_work_memory:
  file.replace:
    - name: /var/lib/pgsql/data/postgresql.conf
    - pattern: 'work_mem = (.*)'
    - repl: 'work_mem = 10MB'
    - append_if_not_found: True
    - require:
      - cmd: server_setup

large_deployment_postgresql:
  service.running:
    - name: postgresql
    - watch:
      - file: large_deployment_increase_database_max_connections
      - file: large_deployment_increase_database_work_memory

{% endif %}

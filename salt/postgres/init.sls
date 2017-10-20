include:
  - default
  - postgres.firewall

postgresql:
  pkg.installed:
    - pkgs:
      - postgresql-init
      - postgresql94-server
      - postgresql94
      - postgresql94-contrib
      - timezone
    - require:
      - sls: default
  service.running:
    - enable: True

postgresql_listen_addresses_configuration:
  file.append:
    - name: /var/lib/pgsql/data/postgresql.conf
    - text: listen_addresses = '*'
    - require:
      - service: postgresql

postgresql_max_connections_configuration:
  file.replace:
    - name: /var/lib/pgsql/data/postgresql.conf
    - pattern: max_connections = .*
    - repl: max_connections = 500
    - require:
      - service: postgresql

postgresql_hba_configuration:
  file.managed:
    - name: /var/lib/pgsql/data/pg_hba.conf
    - contents: |
        local all all           peer
        host  all all 0.0.0.0/0 md5
        host  all all ::0/0     md5
    - require:
      - service: postgresql

# HACK: postgresql.conf and pg_hba.conf are created by Postgres after the first
# time the service starts. As salt prohibites dependency cycles, we force
# restarting the service when those files change
postgresql_restart:
  cmd.run:
    - name: systemctl restart postgresql
    - onchanges:
      - file: postgresql_listen_addresses_configuration
      - file: postgresql_max_connections_configuration
      - file: /var/lib/pgsql/data/pg_hba.conf

postgresql_database_creation:
  cmd.run:
{% if grains['saltversion'] > '2016' %}
    - runas: postgres
{% else %}
    - user: postgres
{% endif %}
    - name: createdb -E UTF8 susemanager
    - unless: psql -l | grep susemanager
    - require:
      - service: postgresql

postgresql_language_configuration:
  cmd.run:
{% if grains['saltversion'] > '2016' %}
    - runas: postgres
{% else %}
    - user: postgres
{% endif %}
    - name: createlang plpgsql susemanager
    - unless: psql susemanager -c "\dL" | grep plpgsql
    - require:
      - cmd: postgresql_database_creation

postgresql_user:
  cmd.run:
{% if grains['saltversion'] > '2016' %}
    - runas: postgres
{% else %}
    - user: postgres
{% endif %}
    - name: echo "CREATE ROLE {{ grains.get('database_user') | default('susemanager') }} PASSWORD '{{ grains.get('database_password') | default('susemanager') }}' SUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;" | psql
    - unless: psql -c "\du" | grep {{ grains.get('database_user') | default('susemanager') }}
    - require:
      - cmd: postgresql_database_creation

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

conf-listen-addresses:
  file.append:
    - name: /var/lib/pgsql/data/postgresql.conf
    - text: listen_addresses = '*'
    - require:
      - service: postgresql

conf-max-connections:
  file.replace:
    - name: /var/lib/pgsql/data/postgresql.conf
    - pattern: max_connections = .*
    - repl: max_connections = 500
    - require:
      - service: postgresql

conf-hba:
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
postgresql-restart:
  cmd.run:
    - name: systemctl restart postgresql
    - onchanges:
      - file: conf-listen-addresses
      - file: conf-max-connections
      - file: /var/lib/pgsql/data/pg_hba.conf

create-db:
  cmd.run:
{% if grains['saltversion'] == '2015.8.12' %}
    - user: postgres
{% else %}
    - runas: postgres
{% endif %}
    - name: createdb -E UTF8 susemanager
    - unless: psql -l | grep susemanager
    - require:
      - service: postgresql

create-plpgsql-lang:
  cmd.run:
{% if grains['saltversion'] == '2015.8.12' %}
    - user: postgres
{% else %}
    - runas: postgres
{% endif %}
    - name: createlang plpgsql susemanager
    - unless: psql susemanager -c "\dL" | grep plpgsql
    - require:
      - cmd: create-db

create-user:
  cmd.run:
{% if grains['saltversion'] == '2015.8.12' %}
      - user: postgres
{% else %}
      - runas: postgres
{% endif %}
    - name: echo "CREATE ROLE spacewalk PASSWORD 'spacewalk' SUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;" | psql
    - unless: psql -c "\du" | grep spacewalk
    - require:
      - cmd: create-db

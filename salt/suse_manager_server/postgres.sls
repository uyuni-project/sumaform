{% if grains['for_development_only'] and grains['database'] == 'postgres' %}

include:
  - suse_manager_server

# allow connections from any host, allow non-durable but faster operation
# see https://www.postgresql.org/docs/current/static/non-durability.html

postgresql_listen_addresses_configuration:
  file.append:
    - name: /var/lib/pgsql/data/postgresql.conf
    - text: |
        listen_addresses = '*'
        fsync = off
        full_page_writes = off
    - require:
      - sls: suse_manager_server

postgresql_hba_configuration:
  file.append:
    - name: /var/lib/pgsql/data/pg_hba.conf
    - text: host    all     all       0.0.0.0/0      md5
    - require:
      - sls: suse_manager_server

postgresql:
  service.running:
    - watch:
      - file: postgresql_listen_addresses_configuration
      - file: postgresql_hba_configuration
    - require:
      - file: postgresql_listen_addresses_configuration
      - file: postgresql_hba_configuration

{% endif %}

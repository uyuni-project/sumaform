{% if grains['for_development_only'] and grains['database'] == 'postgres' %}

include:
  - suse-manager

# allow connections from any host, allow non-durable but faster operation
# see https://www.postgresql.org/docs/current/static/non-durability.html

postgres-config:
  file.append:
    - name: /var/lib/pgsql/data/postgresql.conf
    - text: |
        listen_addresses = '*'
        fsync = off
        full_page_writes = off
    - require:
      - sls: suse-manager

hba-config:
  file.append:
    - name: /var/lib/pgsql/data/pg_hba.conf
    - text: host    all     all       0.0.0.0/0      md5
    - require:
      - sls: suse-manager

postgresql:
  service.running:
    - watch:
      - file: postgres-config
      - file: hba-config
    - require:
      - file: postgres-config
      - file: hba-config

{% endif %}

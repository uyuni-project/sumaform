# Allow connections to Postgres from any host
include:
  - suse-manager

/var/lib/pgsql/data/postgresql.conf:
  file.append:
    - text: listen_addresses = '*'
    - require:
      - sls: suse-manager

/var/lib/pgsql/data/pg_hba.conf:
  file.append:
    - text: host    all     all       0.0.0.0/0      md5
    - require:
      - sls: suse-manager

postgresql:
  service.running:
    - watch:
      - file: /var/lib/pgsql/data/postgresql.conf
      - file: /var/lib/pgsql/data/pg_hba.conf
    - require:
      - file: /var/lib/pgsql/data/postgresql.conf
      - file: /var/lib/pgsql/data/pg_hba.conf

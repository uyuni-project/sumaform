{% if grains['database'] == 'pgpool' %}

include:
  - suse-manager

pgpool-II:
  pkg.latest: []
  user.present:
    - name: pgpool
    - groups:
      - postgres
    - require:
      - pkg: pgpool-II
  service.running:
    - enable: True
    - require:
      - service: postgresql
      - file: socket-dir
      - cmd: generate-pgpool-md5-hash
      - file: config-pgpool-listen-to-all
      - file: config-pgpool-use-default-postgres-port
      - file: config-pgpool-use-default-postgres-socket-dir
      - file: config-pgpool-comment-default-backend
      - file: config-pgpool-configure-backends
      - file: config-pgpool-pool-size
      - file: config-pgpool-enable-replication
      - file: config-pgpool-replicate-select
      - file: config-pgpool-enable-hba
      - file: config-pgpool-hba

config-pgpool-listen-to-all:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^listen_addresses = .*
    - repl: listen_addresses = '*'
    - require:
      - pkg: pgpool-II

config-pgpool-use-default-postgres-port:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^port = .*
    - repl: port = 5432
    - require:
      - pkg: pgpool-II

config-pgpool-use-default-postgres-socket-dir:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^socket_dir = .*
    - repl: socket_dir = '/var/run/postgresql'
    - require:
      - pkg: pgpool-II

config-pgpool-comment-default-backend:
  file.comment:
    - name: /etc/pgpool-II/pgpool.conf
    - regex: ^backend_.*
    - require:
      - pkg: pgpool-II

config-pgpool-configure-backends:
  file.append:
    - name: /etc/pgpool-II/pgpool.conf
    - text: |
        # Inserted by suminator
        backend_hostname0 = 'pg1.tf.local'
        backend_port0 = 5432
        backend_weight0 = 1
        backend_data_directory0 = '/var/lib/pgsql/data'
        backend_flag0 = 'ALLOW_TO_FAILOVER'

        backend_hostname1 = 'pg2.tf.local'
        backend_port1 = 5432
        backend_weight1 = 1
        backend_data_directory1 = '/var/lib/pgsql/data'
        backend_flag1 = 'ALLOW_TO_FAILOVER'
    - require:
      - pkg: pgpool-II

config-pgpool-pool-size:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^num_init_children = .*
    - repl: num_init_children = 100
    - require:
      - pkg: pgpool-II

config-pgpool-enable-replication:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^replication_mode = off
    - repl: replication_mode = on
    - require:
      - pkg: pgpool-II

config-pgpool-replicate-select:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^replicate_select = off
    - repl: replicate_select = on
    - require:
      - pkg: pgpool-II

config-pgpool-enable-hba:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^enable_pool_hba = off
    - repl: enable_pool_hba = on
    - require:
      - pkg: pgpool-II

config-pgpool-hba:
  file.managed:
    - name: /etc/pgpool-II/pool_hba.conf
    - contents: |
        local all all           trust
        host  all all 0.0.0.0/0 md5
        host  all all ::0/0     md5
    - require:
      - pkg: pgpool-II

generate-pgpool-md5-hash:
  cmd.run:
    - name: pg_md5 -m -u spacewalk spacewalk
    - unless: grep spacewalk < /etc/pgpool-II/pool_passwd
    - require:
      - pkg: pgpool-II

# HACK: currently the taskomatic unit requires postgresql
taskomatic-do-not-require-postgres:
  file.comment:
    - name: /usr/lib/systemd/system/taskomatic.service
    - regex: Wants=postgresql.service
    - require:
      - pkg: suse-manager-packages

postgresql:
  service.dead:
    - enable: False
    - require:
      - file: taskomatic-do-not-require-postgres

socket-dir:
  file.directory:
    - name: /var/run/postgresql
    - user: pgpool
    - group: pgpool
    - dir_mode: 771

# HACK: provide newer version of migration.sh
# (until the Manager-3.0-enable-external-postgres branch is merged)
migration-script:
  file.managed:
    - name: /usr/lib/susemanager/bin/migration.sh
    - source: salt://suse-manager/migration.sh

{% endif %}

{% if grains['database'] == 'pgpool' %}

include:
  - suse_manager_server

pgpool:
  pkg.latest:
    - name: pgpool-II
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
      - file: socket_dir
      - cmd: generate_pgpool_md5_hash
      - file: config_pgpool_listen_to_all
      - file: config_pgpool_use_default_postgres_port
      - file: config_pgpool_use_default_postgres_socket_dir
      - file: config_pgpool_comment_default_backend
      - file: config_pgpool_configure_backends
      - file: config_pgpool_pool_size
      - file: config_pgpool_enable_replication
      - file: config_pgpool_replicate_select
      - file: config_pgpool_enable_hba
      - file: config_pgpool_hba

config_pgpool_listen_to_all:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^listen_addresses = .*
    - repl: listen_addresses = '*'
    - require:
      - pkg: pgpool-II

config_pgpool_use_default_postgres_port:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^port = .*
    - repl: port = 5432
    - require:
      - pkg: pgpool-II

config_pgpool_use_default_postgres_socket_dir:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^socket_dir = .*
    - repl: socket_dir = '/var/run/postgresql'
    - require:
      - pkg: pgpool-II

config_pgpool_comment_default_backend:
  file.comment:
    - name: /etc/pgpool-II/pgpool.conf
    - regex: ^backend_.*
    - require:
      - pkg: pgpool-II

config_pgpool_configure_backends:
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

config_pgpool_pool_size:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^num_init_children = .*
    - repl: num_init_children = 100
    - require:
      - pkg: pgpool-II

config_pgpool_enable_replication:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^replication_mode = off
    - repl: replication_mode = on
    - require:
      - pkg: pgpool-II

config_pgpool_replicate_select:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^replicate_select = off
    - repl: replicate_select = on
    - require:
      - pkg: pgpool-II

config_pgpool_enable_hba:
  file.replace:
    - name: /etc/pgpool-II/pgpool.conf
    - pattern: ^enable_pool_hba = off
    - repl: enable_pool_hba = on
    - require:
      - pkg: pgpool-II

config_pgpool_hba:
  file.managed:
    - name: /etc/pgpool-II/pool_hba.conf
    - contents: |
        local all all           trust
        host  all all 0.0.0.0/0 md5
        host  all all ::0/0     md5
    - require:
      - pkg: pgpool-II

generate_pgpool_md5_hash:
  cmd.run:
    - name: pg_md5 -m -u {{ grains.get('database_user') | default('susemanager') }} {{ grains.get('database_password') | default('susemanager') }}
    - unless: grep {{ grains.get('database_user') | default('susemanager') }} < /etc/pgpool-II/pool_passwd
    - require:
      - pkg: pgpool-II

# HACK: currently the taskomatic unit requires postgresql
taskomatic_do_not_require_postgres:
  file.comment:
    - name: /usr/lib/systemd/system/taskomatic.service
    - regex: Wants=postgresql.service
    - require:
      - pkg: suse_manager_packages

postgresql:
  service.dead:
    - enable: False
    - require:
      - file: taskomatic_do_not_require_postgres

socket_dir:
  file.directory:
    - name: /var/run/postgresql
    - user: pgpool
    - group: pgpool
    - dir_mode: 771

# HACK: provide newer version of migration.sh
# (until the Manager-3.0-enable-external-postgres branch is merged)
migration_script:
  file.managed:
    - name: /usr/lib/susemanager/bin/migration.sh
    - source: salt://suse_manager_server/migration.sh

{% endif %}

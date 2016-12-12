{% if grains['for-development-only'] and grains['database'] == 'postgres' %}

include:
  - suse-manager.main

# allow connections from any host

postgres-config:
  file.append:
    - name: /var/lib/pgsql/data/postgresql.conf
    - text: listen_addresses = '*'
    - require:
      - sls: suse-manager.main

hba-config:
  file.append:
    - name: /var/lib/pgsql/data/pg_hba.conf
    - text: host    all     all       0.0.0.0/0      md5
    - require:
      - sls: suse-manager.main

postgresql:
  service.running:
    - watch:
      - file: postgres-config
      - file: hba-config
    - require:
      - file: postgres-config
      - file: hba-config

{% endif %}

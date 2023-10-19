include:
  - server

postgresql_main_configuration:
  file.append:
    - name: /var/lib/pgsql/data/postgresql.conf
    - text:
      {% if grains.get('allow_postgres_connections') %}
      - listen_addresses = '*'
      {% endif %}
      {% if grains.get('unsafe_postgres') %}
      - fsync = off
      - full_page_writes = off
      {% endif %}
      {% if grains.get('postgres_log_min_duration') is not none %}
      - log_min_duration_statement = {{ grains.get('postgres_log_min_duration') }}
      {% endif %}
    - require:
      - sls: server

{% if grains.get('allow_postgres_connections') %}
postgresql_hba_configuration:
  file.append:
    - name: /var/lib/pgsql/data/pg_hba.conf
    - text: |
{%- if grains['product_version'] in ['head', 'beta', '4.3-nightly', '4.3-pr', '4.3-released', '4.3-beta'] %}
        host    all     all       0.0.0.0/0      scram-sha-256
        host    all     all       ::/0           scram-sha-256
{%- else %}
        host    all     all       0.0.0.0/0      md5
        host    all     all       ::/0           md5
{%- endif %}
    - require:
      - sls: server
{% endif %}

postgresql:
  service.running:
    - watch:
      - file: postgresql_main_configuration
{% if grains.get('allow_postgres_connections') %}
      - file: postgresql_hba_configuration
{% endif %}

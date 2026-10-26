{% if grains.get('allow_postgres_connections') and grains.get('container_runtime') | default('podman', true) == 'podman' and grains.get('product_version', '') | regex_search('(5\.1|5\.2|uyuni|head)') %}
# The uyuni-db image regenerates pg_hba.conf on start, custom rules go in pg_hba_custom.conf
postgres_allow_external_connections:
  cmd.run:
    - name: podman exec uyuni-db bash -c "echo 'host all all all scram-sha-256' > /var/lib/pgsql/data/pg_hba_custom.conf" && podman exec uyuni-db su postgres -c "pg_ctl reload -D /var/lib/pgsql/data"
    - unless: podman exec uyuni-db grep -q '^host all all all scram-sha-256' /var/lib/pgsql/data/pg_hba_custom.conf
    - require:
      - sls: server_containerized.install_mgradm
{% endif %}

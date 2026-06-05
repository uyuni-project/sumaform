{% if grains.get('server_hub_peripheral') | default(false, true) %}

{% set hub_fqdn = grains['server_hub_peripheral'] %}
{% set peripheral_fqdn = grains['fqdn'] %}

hub_ssl_build_dir:
  file.directory:
    - name: /root/ssl-build

hub_ca_cert:
  file.managed:
    - name: /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT
    - source: http://{{ hub_fqdn }}/pub/RHN-ORG-TRUSTED-SSL-CERT
    - source_hash: http://{{ hub_fqdn }}/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - file: hub_ssl_build_dir

hub_peripheral_server_cert:
  file.managed:
    - name: /root/ssl-build/peripheral-{{ peripheral_fqdn }}-server.crt
    - source: http://{{ hub_fqdn }}/pub/peripheral-{{ peripheral_fqdn }}-server.crt
    - source_hash: http://{{ hub_fqdn }}/pub/peripheral-{{ peripheral_fqdn }}-server.crt.sha512
    - require:
      - file: hub_ssl_build_dir

hub_peripheral_server_key:
  file.managed:
    - name: /root/ssl-build/peripheral-{{ peripheral_fqdn }}-server.key
    - mode: '0600'
    - source: http://{{ hub_fqdn }}/pub/peripheral-{{ peripheral_fqdn }}-server.key
    - source_hash: http://{{ hub_fqdn }}/pub/peripheral-{{ peripheral_fqdn }}-server.key.sha512
    - require:
      - file: hub_ssl_build_dir

hub_ca_trust_anchor:
  file.managed:
    - name: /etc/pki/trust/anchors/RHN-ORG-TRUSTED-SSL-CERT.pem
    - source: /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT
    - require:
      - file: hub_ca_cert

hub_ca_trust_update:
  cmd.run:
    - name: update-ca-certificates
    - onchanges:
      - file: hub_ca_trust_anchor

mgradm_install:
  cmd.run:
    - name: >-
        mgradm install podman --logLevel=debug --config /root/mgradm.yaml
        --ssl-ca-root /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT
        --ssl-server-cert /root/ssl-build/peripheral-{{ peripheral_fqdn }}-server.crt
        --ssl-server-key /root/ssl-build/peripheral-{{ peripheral_fqdn }}-server.key
        --ssl-db-ca-root /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT
        --ssl-db-cert /root/ssl-build/peripheral-{{ peripheral_fqdn }}-server.crt
        --ssl-db-key /root/ssl-build/peripheral-{{ peripheral_fqdn }}-server.key
        {{ peripheral_fqdn }}
    - unless: podman ps | grep uyuni-server
    - require:
      - sls: server_containerized.install_common
      - sls: server_containerized.install_podman
      - file: mgradm_config
      - file: hub_peripheral_server_cert
      - file: hub_peripheral_server_key
      - cmd: hub_ca_trust_update

{% endif %}

certificate_authority_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/ca.cert.pem
    - source: salt://build_host/certs/ca.cert.pem
    - makedirs: True

update_ca_truststore_registry_build_host:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - file: certificate_authority_certificate

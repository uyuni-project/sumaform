certificate_authority_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/ca.cert.pem
    - source: salt://build_host/certs/ca.cert.pem
    - makedirs: True

{# Do not run update-ca-certificates on SLE15 because there is a#}
{# systemd unit that watches for changes and runs it already: #}
{#   /usr/lib/systemd/system/ca-certificates.path #}
{% if '15' not in grains['osrelease'] %}
update_ca_truststore_registry_build_host:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - file: certificate_authority_certificate
{% endif %}

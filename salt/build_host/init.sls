include:
  - repos

certificate_authority_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/ca.cert.pem
    - source: salt://build_host/certs/ca.cert.pem
    - makedirs: True

{% if '11' in grains['osrelease'] %}

update_ca_truststore_registry_build_host:
  cmd.run:
    - name: cp /etc/pki/trust/anchors/ca.cert.pem /etc/ssl/certs/ && /usr/bin/c_rehash /etc/ssl/certs
    - onchanges:
      - file: certificate_authority_certificate

{% elif '12' in grains['osrelease'] %}

update_ca_truststore_registry_build_host:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - file: certificate_authority_certificate

{# Do not run update-ca-certificates on SLE 15 because there is    #}
{# already a systemd unit that watches for changes and runs it:    #}
{#   /usr/lib/systemd/system/ca-certificates.path                  #}

{% endif %}

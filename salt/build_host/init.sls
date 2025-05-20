include:
  - scc.build_host

certificate_authority_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/ca.cert.pem
    - source: salt://build_host/certs/ca.cert.pem
    - makedirs: True

ssh_private_key:
  file.managed:
    - name: /root/.ssh/id_ed25519
    - source: salt://build_host/keys/id_ed25519
    - makedirs: True
    - user: root
    - group: root
    - mode: 600

ssh_public_key:
  file.managed:
    - name: /root/.ssh/id_ed25519.pub
    - source: salt://build_host/keys/id_ed25519.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 600

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

{% elif '15' in grains['osrelease'] %}

{# Do not run update-ca-certificates on SLE 15 because there is    #}
{# already a systemd unit that watches for changes and runs it:    #}
{#   /usr/lib/systemd/system/ca-certificates.path                  #}

{% if "opensuse" not in grains['oscodename']|lower %}

cloud_flavor_check:
  pkg.installed:
    - name: python-instance-billing-flavor-check

{% endif %}
{% endif %}

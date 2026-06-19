# NOTE: temporary, test-only mechanism. The hub generates each peripheral's
# server certificate and key and publishes them under /pub so the peripheral can
# fetch them over HTTP. This exposes the peripheral private key on the hub's
# public endpoint and is only acceptable on sumaform's trusted, ephemeral test
# networks. The built-in publish/download_private_ssl_key path does not fit here
# (it is gated to the minion role and distributes the CA key for self-signing
# rather than per-host server certs). Replace with a secure transfer if this ever
# needs to leave a test environment.
{% if grains.get('hub_peripheral_fqdns') | default([], true) %}

hub_ca_cert_checksum:
  cmd.run:
    - name: mgrctl exec "sha512sum /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT > /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512 && chmod 644 /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512"
    - unless: mgrctl exec "test -f /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512"
    - require:
      - cmd: mgradm_install

{% for peripheral_fqdn in grains.get('hub_peripheral_fqdns', []) %}

hub_peripheral_generate_cert_{{ peripheral_fqdn }}:
  cmd.run:
    - name: mgrctl exec "rhn-ssl-tool --gen-server --dir=/root/ssl-build --set-hostname={{ peripheral_fqdn }} --set-cname=reportdb --set-cname=db --password=spacewalk"
    - unless: mgrctl exec "find /root/ssl-build -maxdepth 2 -name 'server.crt' -path '*{{ peripheral_fqdn.split('.')[0] }}*' | grep -q ."
    - require:
      - cmd: mgradm_install
      - cmd: hub_ca_cert_checksum

hub_peripheral_publish_cert_{{ peripheral_fqdn }}:
  cmd.run:
    - name: |
        CERT_DIR=$(mgrctl exec "find /root/ssl-build -maxdepth 1 -type d -name '{{ peripheral_fqdn.split('.')[0] }}*' | head -1")
        mgrctl exec "cp ${CERT_DIR}/server.crt /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.crt && chmod 644 /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.crt"
        mgrctl exec "sha512sum /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.crt > /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.crt.sha512"
        mgrctl exec "cp ${CERT_DIR}/server.key /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.key && chmod 644 /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.key"
        mgrctl exec "sha512sum /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.key > /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.key.sha512"
    - onchanges:
      - cmd: hub_peripheral_generate_cert_{{ peripheral_fqdn }}

{% endfor %}

{% endif %}

{% if grains.get('hub_peripheral_fqdns') | default([], true) %}

{% for peripheral_fqdn in grains.get('hub_peripheral_fqdns', []) %}

hub_peripheral_generate_cert_{{ peripheral_fqdn }}:
  cmd.run:
    - name: mgrctl exec "rhn-ssl-tool --gen-server --dir=/root/ssl-build --set-hostname={{ peripheral_fqdn }} --set-cname=reportdb --set-cname=db"
    - unless: mgrctl exec "test -f /root/ssl-build/{{ peripheral_fqdn }}/server.crt"
    - require:
      - cmd: mgradm_install

hub_peripheral_publish_cert_{{ peripheral_fqdn }}:
  cmd.run:
    - name: |
        mgrctl exec "cp /root/ssl-build/{{ peripheral_fqdn }}/server.crt /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.crt && chmod 644 /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.crt"
        mgrctl exec "sha512sum /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.crt > /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.crt.sha512"
        mgrctl exec "cp /root/ssl-build/{{ peripheral_fqdn }}/server.key /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.key && chmod 644 /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.key"
        mgrctl exec "sha512sum /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.key > /srv/www/htdocs/pub/peripheral-{{ peripheral_fqdn }}-server.key.sha512"
    - onchanges:
      - cmd: hub_peripheral_generate_cert_{{ peripheral_fqdn }}

{% endfor %}

{% endif %}

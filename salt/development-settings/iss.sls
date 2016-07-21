include:
  - suse-manager
  - development-settings.rhn

{% if grains['iss-slave'] %}

ca-cert-checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT > /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - sls: suse-manager

/root/register_slave.py:
  cmd.script:
    - source: salt://development-settings/register_slave.py
    - args: "admin admin {{ grains['iss-slave'] }}"
    - require:
      - sls: development-settings.rhn

{% elif grains['iss-master'] %}

/root/register_master.py:
  cmd.script:
    - source: salt://development-settings/register_master.py
    - args: "admin admin {{ grains['iss-master'] }}"
    - require:
      - sls: development-settings.rhn

/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT:
  file.managed:
    - source: http://{{grains['iss-master']}}/pub/RHN-ORG-TRUSTED-SSL-CERT
    - source_hash: http://{{grains['iss-master']}}/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512

{% endif %}

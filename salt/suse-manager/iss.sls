{% if grains['for-development-only'] %}

include:
  - suse-manager.rhn

{% if grains['iss-slave'] %}

ca-cert-checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT > /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - sls: suse-manager.rhn

register-slave:
  cmd.script:
    - name: salt://suse-manager/register_slave.py
    - args: "admin admin {{ grains['iss-slave'] }}"
    - require:
      - sls: suse-manager.rhn

{% elif grains['iss-master'] %}

register-master:
  cmd.script:
    - name: salt://suse-manager/register_master.py
    - args: "admin admin {{ grains['iss-master'] }}"
    - require:
      - sls: suse-manager.rhn

master-ssl-cert:
  file.managed:
    - name: /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
    - source: http://{{grains['iss-master']}}/pub/RHN-ORG-TRUSTED-SSL-CERT
    - source_hash: http://{{grains['iss-master']}}/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512

{% endif %}

{% endif %}

{% if grains['for_development_only'] %}

include:
  - suse-manager.rhn

{% if grains['iss_slave'] %}

register_slave:
  cmd.script:
    - name: salt://suse-manager/register_slave.py
    - args: "admin admin {{ grains['iss_slave'] }}"
    - require:
      - sls: suse-manager.rhn

{% elif grains['iss_master'] %}

register_master:
  cmd.script:
    - name: salt://suse-manager/register_master.py
    - args: "admin admin {{ grains['iss_master'] }}"
    - require:
      - sls: suse-manager.rhn

master_ssl_cert:
  file.managed:
    - name: /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
    - source: http://{{grains['iss_master']}}/pub/RHN-ORG-TRUSTED-SSL-CERT
    - source_hash: http://{{grains['iss_master']}}/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512

{% endif %}

{% endif %}

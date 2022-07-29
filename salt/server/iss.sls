include:
  - server.initial_content

{% if grains.get('iss_slave']) %}

register_slave:
  cmd.script:
    - name: salt://server/register_slave.py
    - template: jinja
    - args: "{{ grains.get('server_username') | default('admin', true) }} {{ grains.get('server_password') | default('admin', true) }} {{ grains.get('fqdn') | default('localhost', true) }} {{ grains['iss_slave'] }}"
    - require:
      - sls: server.initial_content

{% elif grains.get('iss_master') %}

register_master:
  cmd.script:
    - name: salt://server/register_master.py
    - template: jinja
    - args: "{{ grains.get('server_username') | default('admin', true) }} {{ grains.get('server_password') | default('admin', true) }} {{ grains['iss_master'] }} {{ grains.get('fqdn') | default('localhost', true) }}"
    - require:
      - sls: server.initial_content

master_ssl_cert:
  file.managed:
    - name: /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
    - source: http://{{grains['iss_master']}}/pub/RHN-ORG-TRUSTED-SSL-CERT
    - source_hash: http://{{grains['iss_master']}}/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - sls: server.initial_content

{% endif %}

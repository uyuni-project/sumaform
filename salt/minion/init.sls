include:
  - minion.testsuite
  - minion.repos

minion:
  pkg.installed:
    - name: salt-minion
    - require:
      - sls: minion.repos
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - pkg: salt-minion
{% if grains['for_development_only'] %}
      - file: master_configuration
{% endif %}

{% if grains['os'] == 'SUSE' and grains['for_testsuite_only'] and grains['container_build_host'] %}

inst_ca-certificates:
  pkg.installed:
    - name: ca-certificates

registry_cert:
  file.managed:
    - name: /etc/pki/trust/anchors/registry.mgr.suse.de.pem
    - source: salt://minion/certs/registry.mgr.suse.de.pem
    - makedirs: True

suse_cert:
  file.managed:
    - name: /etc/pki/trust/anchors/SUSE_Trust_Root.crt.pem
    - source: salt://minion/certs/SUSE_Trust_Root.crt.pem
    - makedirs: True

update_ca_truststore:
  cmd.wait:
    - name: /usr/sbin/update-ca-certificates
    - watch:
      - file: registry_cert
      - file: suse_cert
    - require:
      - pkg: inst_ca-certificates

{% endif %}

{% if grains['for_development_only'] %}

master_configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
    - require:
        - pkg: salt-minion

{% endif %}

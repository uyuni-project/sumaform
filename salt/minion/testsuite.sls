{% if grains['for_testsuite_only'] %}

include:
  - minion.repos

cucumber_requisites:
  pkg.installed:
    - pkgs:
      - salt-minion
      - openscap-extra-probes
      - openscap-utils
      {% if grains['os'] == 'SUSE' %}
      - openscap-content
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
      - aaa_base-extras
      {% endif %}
    - require:
      - sls: minion.repos

testsuite_authorized_key:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://controller/id_rsa.pub
    - makedirs: True

{% if grains['os'] == 'SUSE' and grains['osrelease'] == '12.2' %}

certificates:
  pkg.installed:
    - name: ca-certificates
    - require:
      - sls: minion.repos

registry_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/registry.mgr.suse.de.pem
    - source: salt://minion/certs/registry.mgr.suse.de.pem
    - makedirs: True

suse_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/SUSE_Trust_Root.crt.pem
    - source: salt://minion/certs/SUSE_Trust_Root.crt.pem
    - makedirs: True

update_ca_truststore:
  cmd.wait:
    - name: /usr/sbin/update-ca-certificates
    - watch:
      - file: registry_certificate
      - file: suse_certificate
    - require:
      - pkg: certificates

{% endif %}

{% endif %}

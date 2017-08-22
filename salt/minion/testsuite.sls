{% if grains['for_testsuite_only'] %}

include:
  - minion.repos

# this can break other imp. pkg. alone is better
openscap-extra-probes_minion:
  pkg.installed:
    - name: openscap-extra-probes

cucumber_requisites:
  pkg.installed:
    - pkgs:
      - salt-minion
      - openscap-utils
      {% if grains['os'] == 'SUSE' %}
      - openscap-content
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
      {% if '12' in grains['osrelease'] %}
      - aaa_base-extras
      {% endif %}
      {% endif %}
    - require:
      - sls: minion.repos

{% if grains['os'] == 'SUSE' and '12' in grains['osrelease'] %}

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

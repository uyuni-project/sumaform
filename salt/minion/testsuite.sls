{% if grains.get('testsuite') | default(false, true) %}

include:
  - repos
  - minion

minion_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - salt-minion
      - openscap-utils
    - require:
      - sls: default

{% if grains['os'] == 'SUSE' %}

suse_minion_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - openscap-content
      {% if '12' in grains['osrelease'] or '15' in grains['osrelease']%}
      - aaa_base-extras
      - ca-certificates
      {% endif %}
    - require:
      - sls: repos

{% if '12' in grains['osrelease'] or '15' in grains['osrelease'] %}
registry_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/registry.mgr.suse.de.pem
    - source: salt://minion/certs/registry.mgr.suse.de.pem
    - makedirs: True

portus_registry_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/portus.mgr.suse.de-ca.crt
    - source: salt://minion/certs/portus.mgr.suse.de-ca.crt
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
      - pkg: suse_minion_cucumber_requisites

kiwi-desc-saltboot-installed:
  pkg.installed:
    - name: kiwi-desc-saltboot
    - require:
      - sls: repos

{% endif %}

{% endif %}

{% endif %}

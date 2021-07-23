{% if grains.get('testsuite') | default(false, true) %}

include:
  - repos
  - minion

minion_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - salt-minion
      - wget
    - require:
      - sls: default

{% if grains['os'] == 'SUSE' %}
{% if '12' in grains['osrelease'] or '15' in grains['osrelease']%}

suse_minion_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - aaa_base-extras
      - ca-certificates
    - require:
      - sls: repos

registry_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/registry.mgr.suse.de.pem
    - source: salt://minion/certs/registry.mgr.suse.de.pem
    - makedirs: True

auth_registry_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/portus.mgr.suse.de-ca.crt
    - source: salt://minion/certs/portus.mgr.suse.de-ca.crt
    - makedirs: True

suse_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/SUSE_Trust_Root.crt.pem
    - source: salt://minion/certs/SUSE_Trust_Root.crt.pem
    - makedirs: True

{% endif %}

{% endif %}

{% endif %}

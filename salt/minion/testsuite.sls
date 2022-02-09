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

suse_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/SUSE_Trust_Root.crt.pem
    - source: salt://minion/certs/SUSE_Trust_Root.crt.pem
    - makedirs: True

update_ca_truststore:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - file: suse_certificate
    - require:
      - pkg: suse_minion_cucumber_requisites
    - unless:
      - fun: service.status
        args:
          - ca-certificates.path

{% endif %}
{% endif %}

{% endif %}

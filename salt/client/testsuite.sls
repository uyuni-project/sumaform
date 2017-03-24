{% if grains['for_testsuite_only'] %}

include:
  - client.repos

cucumber_requisites:
  pkg.installed:
    - pkgs:
      - subscription-tools
      - spacewalk-client-setup
      - spacewalk-check
      - spacewalk-oscap
      - rhncfg-actions
      - openscap-extra-probes
      - openscap-utils
      - man
      - wget
      - adaptec-firmware
      {% if grains['os'] == 'SUSE' %}
      - openscap-content
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
      - aaa_base-extras
      {% endif %}
    - require:
      - sls: client.repos

testsuite_authorized_key:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://controller/id_rsa.pub
    - makedirs: True
{% endif %}

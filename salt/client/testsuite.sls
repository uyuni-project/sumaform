{% if grains['for-testsuite-only'] %}

include:
  - client.repos

cucumber-requisites:
  pkg.installed:
    - pkgs:
      - subscription-tools
      - spacewalk-client-setup
      - spacewalk-check
      - spacewalk-oscap
      - rhncfg-actions
      - andromeda-dummy 
      - milkyway-dummy
      - virgo-dummy
      - openscap-content
      - openscap-extra-probes
      - openscap-utils
      - man
      - wget
      - adaptec-firmware
      - aaa_base-extras
    - require:
      - sls: client.repos

testsuite-authorized-key:
  file.managed:
    - name: /root/.ssh/authorized_keys
    - source: salt://control-node/id_rsa.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700
{% endif %}

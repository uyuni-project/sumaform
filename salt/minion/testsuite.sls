{% if grains['for-testsuite-only'] %}

include:
  - client.repos

cucumber-requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy 
      - milkyway-dummy 
      - virgo-dummy
      - salt-minion
      - aaa_base-extras
    - require:
      - sls: client.repos

testsuite-authorized-key:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://control-node/id_rsa.pub
    - makedirs: True

{% endif %}

{% if grains['for_testsuite_only'] %}

include:
  - client.repos

cucumber-requisites:
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
      - sls: client.repos

testsuite-authorized-key:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://control-node/id_rsa.pub
    - makedirs: True

{% endif %}

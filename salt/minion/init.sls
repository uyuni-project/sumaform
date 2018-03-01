include:
  - minion.testsuite

minion_package:
  pkg.installed:
    - name: salt-minion
    - require:
      - sls: default

minion_id:
  file.managed:
    - name: /etc/salt/minion_id
    - contents: {{ grains['hostname'] }}.{{ grains['domain'] }}

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - pkg: salt-minion
{% if grains.get('auto_connect_to_master') | default(true, true) %}
    - listen:
      - file: /etc/salt/minion.d/master.conf
      - file: /etc/salt/minion_id

master_configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
    - require:
      - pkg: salt-minion
{% endif %}

include:
  - minion.testsuite
  - minion.repos

minion_package:
  pkg.installed:
    - name: salt-minion
    - require:
      - sls: minion.repos

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
{% if grains['for_development_only'] %}
    - listen:
      - file: /etc/salt/minion.d/master.conf
      - file: /etc/salt/minion_id
{% endif %}

{% if grains['for_development_only'] %}
master_configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
    - require:
      - pkg: salt-minion
{% endif %}

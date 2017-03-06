include:
  - client.repos
  - minion.testsuite
  - minion.repos

minion:
  pkg.installed:
    - name: salt-minion
    - require:
      - sls: minion.repos
      - sls: client.repos
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - pkg: salt-minion
{% if grains['for-development-only'] %}
      - file: master-configuration
{% endif %}


{% if grains['for-development-only'] %}

master-configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
    - require:
        - pkg: salt-minion

{% endif %}

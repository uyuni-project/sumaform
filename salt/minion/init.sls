include:
  - client.repos
  - minion.testsuite

salt-minion:
  pkg.installed:
    - require:
      - sls: client.repos
  service.running:
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

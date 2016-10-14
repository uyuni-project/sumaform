include:
  - client.repos

salt-minion:
  pkg.installed:
    - require:
      - sls: client.repos
  service.running:
    - enable: True
    - watch:
      - pkg: salt-minion
      - file: master-configuration

master-configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
    - require:
        - pkg: salt-minion

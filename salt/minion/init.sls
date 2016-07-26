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
      - file: /etc/salt/minion.d/master.conf

/etc/salt/minion.d/master.conf:
  file.managed:
    - contents: |
        master: {{grains['server']}}
    - require:
        - pkg: salt-minion

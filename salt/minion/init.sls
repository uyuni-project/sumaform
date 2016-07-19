include:
  - client.repos

refresh-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: client.repos

salt-minion:
  pkg.installed: []
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

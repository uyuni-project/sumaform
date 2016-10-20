/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-setup-minion:
  file.managed:
      - name: /root/.ssh/authorized_keys
      - source: salt://test-minion/authorized_keys

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

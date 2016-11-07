include:
  - test-client.repos
  - sles.repos
  - client.repos

cucumber-prereq-minion:
  pkg.installed:
    - pkgs:
      - andromeda-dummy 
      - milkyway-dummy 
      - virgo-dummy
      - salt-minion
      - aaa_base-extras
    - require:
      - sls: test-client.repos
      - sls: sles.repos
      - sls: client.repos

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-setup-minion:
  file.managed:
      - name: /root/.ssh/authorized_keys
      - source: salt://test-minion/authorized_keys

salt-minion:
  service.running:
    - enable: True

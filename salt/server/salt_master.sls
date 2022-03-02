include:
  - server

custom_salt_master_configuration:
  file.managed:
    - name: /etc/salt/master.d/zz-custom.conf
    - source: salt://server/master-custom.conf
    - template: jinja
    - require:
        - sls: server

salt_master:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - file: custom_salt_master_configuration

salt_api:
  service.running:
    - name: salt-api
    - enable: True
    - watch:
      - file: custom_salt_master_configuration

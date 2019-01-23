include:
  - suse_manager_server

custom_salt_master_configuration:
  file.managed:
    - name: /etc/salt/master.d/custom.conf
    - source: salt://suse_manager_server/master-custom.conf
    - template: jinja
    - require:
        - sls: suse_manager_server

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

# HACK: work around bsc1122837
patch_salt_minion_sls:
  file.patch:
    - name: /usr/share/susemanager/salt/services/salt-minion.sls
    - source: salt://suse_manager_server/salt-minion-sls.patch
    - hash: 83fe6d5ca6e5209a10ba4a2b75b82705

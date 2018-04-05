{% if grains.get('auto_accept') %}

include:
  - suse_manager_server

custom_salt_master_configuration:
  file.managed:
    - name: /etc/salt/master.d/custom.conf
    - source: salt://suse_manager_server/master-custom.conf
    - require:
        - sls: suse_manager_server

salt_master:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - file: custom_salt_master_configuration
{% endif %}

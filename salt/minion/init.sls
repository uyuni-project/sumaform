include:
  - scc.minion
  - repos
  - minion.testsuite
  - minion.reflector

minion_package:
  pkg.installed:
    - name: salt-minion
    - require:
      - sls: default

{% if grains.get('evil_minion_count') %}
evil_minions_package:
  pkg.installed:
    - name: evil-minions

evil_minions_systemd_configuration:
  file.replace:
    - name: /etc/systemd/system/salt-minion.service.d/override.conf
    - pattern: ExecStart=(.+)
    - repl: ExecStart=/usr/bin/evil-minions --count {{grains['evil_minion_count']}} --slowdown-factor {{grains['evil_minion_slowdown_factor']}} --id-prefix {{grains.get('hostname') | default('evil', true)}}

reload_systemd_modules:
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: evil_minions_systemd_configuration
{% endif %}

minion_id:
  file.managed:
    - name: /etc/salt/minion_id
    - contents: {{ grains['hostname'] }}.{{ grains['domain'] }}

{% if grains.get('auto_connect_to_master') %}
master_configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
        server_id_use_crc: adler32
        enable_legacy_startup_events: False
        enable_fqdns_grains: False
        start_event_grains:
          - machine_id
          - saltboot_initrd
          - susemanager
{% endif %}

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
{% if grains.get('auto_connect_to_master') %}
    - watch:
      - file: master_configuration
{% endif %}

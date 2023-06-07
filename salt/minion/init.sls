include:
  - scc.minion
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  - minion.testsuite
  - minion.reflector

{% if not grains['osfullname'] == 'SLE Micro' %}
# Dependencies already satisfied by the images
# https://build.opensuse.org/project/show/systemsmanagement:sumaform:images:microos
minion_package:
  pkg.installed:
{% if grains['install_salt_bundle'] %}
    - name: venv-salt-minion
{% else %}
    - name: salt-minion
{% endif %}
    - require:
      - sls: default
{% endif %}

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
{% if grains['install_salt_bundle'] %}
    - name: /etc/venv-salt-minion/minion_id
{% else %}
    - name: /etc/salt/minion_id
{% endif %}
    - contents: {{ grains['hostname'] }}.{{ grains['domain'] }}

{% if grains.get('auto_connect_to_master') %}
master_configuration:
  file.managed:
    {% if grains.get('install_salt_bundle') %}
    - name: /etc/venv-salt-minion/minion.d/master.conf
    {% else %}
    - name: /etc/salt/minion.d/master.conf
    {% endif %}
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
{% if grains['install_salt_bundle'] %}
    - name: venv-salt-minion
    - enable: True
{% else %}
    - name: salt-minion
    - enable: True
{% endif %}
{% if grains.get('auto_connect_to_master') %}
    - watch:
      - file: master_configuration
{% endif %}

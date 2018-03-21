include:
  - minion.testsuite
{% if grains.get('evil_minions_dump') %}
  - evil_minions.repos
{% endif %}
  - minion.apparmor

minion_package:
  pkg.installed:
    - name: salt-minion
    - require:
      - sls: default

{% if grains.get('evil_minions_dump') %}
evil_minions_package:
  pkg.installed:
    - name: evil-minions
    - require:
      - cmd: refresh_tools_repo

evil_minions_systemd_service:
  file.replace:
    - name: /usr/lib/systemd/system/salt-minion.service
    - pattern: ExecStart(.*)
    - repl: ExecStart=/usr/bin/dumping-salt-minion
    - require:
      - pkg: evil_minions_package
      - pkg: salt-minion

reload_systemd_modules:
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /usr/lib/systemd/system/salt-minion.service
{% endif %}

minion_id:
  file.managed:
    - name: /etc/salt/minion_id
    - contents: {{ grains['hostname'] }}.{{ grains['domain'] }}

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - pkg: salt-minion
  {% if grains.get('evil_minions_dump') or grains.get('auto_connect_to_master') %}
    - listen:
  {% if grains.get('evil_minions_dump') %}
      - file: evil_minions_systemd_service
  {% endif %}
  {% if grains.get('auto_connect_to_master') %}
      - file: /etc/salt/minion.d/master.conf
      - file: /etc/salt/minion_id
  {% endif %}
  {% endif %}

{% if grains.get('auto_connect_to_master') %}
master_configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
    - require:
      - pkg: salt-minion
{% endif %}

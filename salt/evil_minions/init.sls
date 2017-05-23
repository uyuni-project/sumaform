include:
  - evil_minions.repos

disable_salt_minion:
  service.disabled:
    - name: salt-minion

install_evil_minions:
{% if grains.get('install_from_git') %}
  pkg.installed:
    - name: git-core

  git.latest:
    - name: https://github.com/moio/evil-minions
    - target: /root/evil-minions
    - require:
      - pkg: git-core
{% else %}
  archive.extracted:
    - name: /root/
    - source: salt://evil_minions/evil-minions.tar.gz
{% endif %}

install_minion_dump_yaml_file:
  file.decode:
    - name: /root/minion-dump.yml
    - encoding_type: base64
    - encoded_data: {{ grains['minion_dump_yaml'] }}

evil_minions_service:
  file.managed:
    - name: /etc/systemd/system/evil-minions.service
    - contents: |
        [Unit]
        Description=evil-minions

        [Service]
        ExecStart=/root/evil-minions/evil-minions --count {{grains["evil_minion_count"]}} --processes {{grains['num_cpus']}} --dump-path /root/minion-dump.yml --slowdown-factor {{grains['slowdown_factor']}} --id-prefix {{grains['id']}} {{grains['server']}}

        [Install]
        WantedBy=multi-user.target
    - require:
{% if grains.get('install_from_git') %}
      - git: install_evil_minions
{% else %}
      - archive: install_evil_minions
{% endif %}
      - file: install_minion_dump_yaml_file

  service.running:
    - name: evil-minions
    - enable: True
    - require:
      - file: evil_minions_service

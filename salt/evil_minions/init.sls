include:
  - evil_minions.repos

disable_salt_minion:
  service.disabled:
    - name: salt-minion

install_evil_minions:
  pkg.installed:
    - name: evil-minions
    - require:
      - cmd: refresh_tools_repo

install_dump_file:
  file.decode:
    - name: /root/minion-dump.mp
    - encoding_type: base64
    - encoded_data: {{ grains['dump'] }}

evil_minions_service:
  file.managed:
    - name: /etc/systemd/system/evil-minions.service
    - contents: |
        [Unit]
        Description=evil-minions

        [Service]
        ExecStart=/usr/bin/evil-minions --count {{grains["evil_minion_count"]}} --processes {{grains['num_cpus']}} --dump-path /root/minion-dump.mp --slowdown-factor {{grains['slowdown_factor']}} --id-prefix {{grains.get('hostname') | default('evil', true)}} {{grains['server']}}
        LimitNOFILE=512000

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: install_evil_minions
      - file: install_dump_file

  service.running:
    - name: evil-minions
    - enable: True
    - require:
      - file: evil_minions_service

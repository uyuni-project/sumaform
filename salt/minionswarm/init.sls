include:
  - repos

salt_master:
  pkg.installed:
    - name: salt-master
    - require:
      - sls: repos

patch:
  pkg.installed:
    - require:
      - sls: default

file_client_race_condition_fix:
  file.patch:
    - name: /usr/lib/python2.7/site-packages/salt/fileclient.py
    - source: salt://minionswarm/0001-Fix-race-condition-on-cache-directory-creation.patch
    - hash: sha1:b90c28cb3993333c3efcccf59c50f4dc196f809d
    - require:
      - pkg: patch
      - pkg: salt_master

minionswarm_script:
  file.managed:
    - name: /usr/bin/minionswarm.py
    - source: salt://minionswarm/minionswarm.py
    - mode: 700
    - require:
      - pkg: salt-master
      - file: file_client_race_condition_fix
      - mount: file_swap

minionswarm_configuration:
  file.managed:
    - name: /etc/minionswarm/minion
    - makedirs: True
    - contents: |
        mine_return_job: True

minionswarm_service:
  file.managed:
    - name: /etc/systemd/system/minionswarm.service
    - contents: |
        [Unit]
        Description=minionswarm

        [Service]
        ExecStart=/usr/bin/minionswarm.py --minions {{grains["minion_count"]}} --start-delay {{grains["start_delay"]}} --master {{grains['server']}} --name {{grains['hostname']}} --no-clean --temp-dir=/tmp/swarm --rand-machine-id --rand-uuid --rand-ver --config-dir=/etc/minionswarm

        [Install]
        WantedBy=multi-user.target
    - require:
      - file: minionswarm_script
      - file: minionswarm_configuration
  service.running:
    - name: minionswarm
    - enable: True
    - require:
      - file: minionswarm_service

suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default

refresh_suse_manager_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: suse_manager_pool_repo
      - file: suse_manager_pool_repo

{% if grains.has_key('swap_file_size') %}
file_swap:
  cmd.run:
    - name: |
        fallocate --length {{grains["swap_file_size"]}}MiB /swapfile
        chmod 0600 /swapfile
        mkswap /swapfile
        swapon -a
    - creates: /swapfile
  mount.swap:
    - name: /swapfile
    - persist: true
    - require:
      - cmd: file_swap
{% endif %}

salt_master:
  pkg.installed:
    - name: salt-master
    - require:
      - cmd: refresh_suse_manager_repos

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

minionswarm_service:
  file.managed:
    - name: /etc/systemd/system/minionswarm.service
    - contents: |
        [Unit]
        Description=minionswarm

        [Service]
        ExecStart=/usr/bin/minionswarm.py --minions {{grains["minion_count"]}} --start-delay {{grains["start_delay"]}} --master {{grains['server']}} --name {{grains['hostname']}} --no-clean --temp-dir=/tmp/swarm --rand-machine-id --rand-uuid --rand-ver

        [Install]
        WantedBy=multi-user.target
    - require:
      - file: minionswarm_script
  service.running:
    - name: minionswarm
    - enable: True
    - require:
      - file: minionswarm_service

suse-manager-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse-manager-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default

refresh-suse-manager-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: suse-manager-pool-repo
      - file: suse-manager-update-repo

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

salt-master:
  pkg.installed:
    - require:
      - cmd: refresh-suse-manager-repos

patch:
  pkg.installed:
    - require:
      - sls: default

file-client-race-condition-fix:
  file.patch:
    - name: /usr/lib/python2.7/site-packages/salt/fileclient.py
    - source: salt://minionswarm/0001-Fix-race-condition-on-cache-directory-creation.patch
    - hash: sha1:b90c28cb3993333c3efcccf59c50f4dc196f809d
    - require:
      - pkg: patch
      - pkg: salt-master

minionswarm-script:
  file.managed:
    - name: /usr/bin/minionswarm.py
    - source: salt://minionswarm/minionswarm.py
    - mode: 700
    - require:
      - pkg: salt-master
      - file: file-client-race-condition-fix
      - mount: file_swap

minionswarm-service:
  file.managed:
    - name: /etc/systemd/system/minionswarm.service
    - contents: |
        [Unit]
        Description=minionswarm

        [Service]
        ExecStart=/usr/bin/minionswarm.py --minions {{grains["minion-count"]}} --start-delay {{grains["start-delay"]}} --master {{grains['server']}} --name {{grains['hostname']}} --no-clean --temp-dir=/tmp/swarm --rand-machine-id --rand-uuid --rand-ver

        [Install]
        WantedBy=multi-user.target
    - require:
      - file: minionswarm-script
  service.running:
    - name: minionswarm
    - enable: True
    - require:
      - file: minionswarm-service

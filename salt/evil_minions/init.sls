include:
  - evil_minions.repos

master_configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{ grains['server'] }}

disable_salt_minion:
  service.disabled:
    - name: salt-minion
    - require:
      - file: master_configuration

install_evil_minions:
  pkg.installed:
    - name: git-core

  git.latest:
    - name: https://github.com/moio/evil-minions
    - target: /root/evil-minions
    - require:
      - pkg: git-core

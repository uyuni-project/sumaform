include:
  - suse_manager_server
  - suse_manager_deepsea_server.repos

deepsea_packages:
  pkg.latest:
    - pkgs:
      - deepsea
      - gptfdisk
    - require:
      - sls: suse_manager_server
      - sls: suse_manager_deepsea_server.repos

debug_packages:
  pkg.latest:
    - pkgs:
      - tmate
      - netcat-openbsd
    - require:
      - sls: suse_manager_server
      - sls: suse_manager_deepsea_server.repos

install_pip:
  cmd.run:
    - name: curl https://bootstrap.pypa.io/get-pip.py | python
    - require:
      - sls: suse_manager_server
  pip.installed:
    - name: rpdb
    - upgrade: True

create_ssh_keys:
  cmd.run:
    - name: ssh-keygen -q -N '' -f /root/.ssh/id_rsa
    - require:
      - sls: suse_manager_server

suse_tmate_setup:
  file.managed:
    - name: /root/.tmate.conf
    - source: salt://suse_manager_deepsea_server/.tmate.conf

setup_ntpd:
  service.running:
    - name: ntpd

create_proposal_folder:
  file.directory:
    - name: /srv/pillar/ceph/proposals/
    - user: salt
    - group: salt
    - makedirs: True

deepsea:
  service.disabled:
    - name: apparmor
  file.managed:
    - name: /srv/pillar/ceph/proposals/policy.cfg
    - source: salt://suse_manager_deepsea_server/policy.cfg
    - require:
      - file: create_proposal_folder

master_minion:
  pkg.installed:
    - name: salt-minion
    - require:
      - sls: suse_manager_server.repos
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - pkg: salt-minion

master_minion_master_configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['hostname']}}
    - require:
        - pkg: salt-minion

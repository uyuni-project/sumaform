include:
  - suse_manager_server
  - suse_manager_deepsea_server.repos

deepsea_packages:
  pkg.latest:
    - pkgs:
      - deepsea
      - tmate
    - require:
      - sls: suse_manager_server
      - sls: suse_manager_deepsea_server.repos

create_ssh_keys:
  cmd.run:
    - name: ssh-keygen -q -N '' -f /root/.ssh/id_rsa
    - require:
      - sls: suse_manager_server

suse_tmate_setup:
  file.managed:
    - name: /root/.tmate.conf
    - source: salt://suse_manager_deepsea_server/.tmate.conf
    - require:
      - sls: suse_manager_server

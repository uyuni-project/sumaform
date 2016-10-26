init-minion-repo:
  cmd.run:
    - name: |
        zypper ar http://download.suse.de/ibs/Devel:/Galaxy:/BuildRepo/SLE_12_SP1/Devel:Galaxy:BuildRepo.repo
        zypper ar http://dist.suse.de/install/SLP/SLE-12-SP1-Server-GM/x86_64/DVD1/ sles-12-sp1
        zypper -n --gpg-auto-import-keys ref
 
cucumber-prereq-minion:

  pkg.installed:
    - pkgs:
      - andromeda-dummy 
      - milkyway-dummy 
      - virgo-dummy


/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-setup-minion:
  file.managed:
      - name: /root/.ssh/authorized_keys
      - source: salt://test-minion/authorized_keys

include:
  - client.repos

salt-minion:
  pkg.installed:
    - require:
      - sls: client.repos
  service.running:
    - enable: True

aaa_base-extras:
   pkg.installed

init-client-repo:
  cmd.run:
    - name: |
        zypper ar http://download.suse.de/ibs/Devel:/Galaxy:/BuildRepo/SLE_12_SP1/Devel:Galaxy:BuildRepo.repo
        zypper ar http://dist.suse.de/install/SLP/SLE-12-SP1-Server-GM/x86_64/DVD1/ sles-12-sp1
        # FIXME: this repo should be removed
        zypper ar http://download.suse.de/ibs/SUSE/Updates/SUSE-Manager-Server/3.0/x86_64/update/SUSE:Updates:SUSE-Manager-Server:3.0:x86_64.repo
        zypper -n --gpg-auto-import-keys ref


cucumber-prereq:
  
  pkg.installed:
    - pkgs:
      - subscription-tools
      - spacewalk-client-setup
      - spacewalk-check
      - spacewalk-oscap
      - rhncfg-actions
      - andromeda-dummy 
      - milkyway-dummy
      - virgo-dummy
      - openscap-content
      - openscap-extra-probes
      - openscap-utils

include:
  - client.repos

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-setup:
  file.managed:
      - name: /root/.ssh/authorized_keys
      - source: salt://test-client/authorized_keys
wget:
  pkg.installed:
    - require:
      - sls: client.repos

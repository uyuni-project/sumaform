include:
  - client.repos
  - test-client.repos
  - sles.repos

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
      - man
      - wget
      - adaptec-firmware
    - require:
      - sls: client.repos
      - sls: test-client.repos
      - sls: sles.repos

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-setup:
  file.managed:
      - name: /root/.ssh/authorized_keys
      - source: salt://test-client/authorized_keys

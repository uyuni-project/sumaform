include:
  - suse-manager.repos

suse-firewall:
  pkg.installed:
    - name: SuSEfirewall2
    - require:
      - sls: suse-manager.repos

open-fw-ports:
  file.replace:
    - name: /etc/sysconfig/SuSEfirewall2
    - pattern: |
        ^FW_SERVICES_EXT_TCP
    - repl: |
        FW_SERVICES_EXT_TCP="http https ssh xmpp-client xmpp-server tftp 1521 5432 4505 4506"
    - append_if_not_found: True
    - require:
      - pkg: suse-firewall

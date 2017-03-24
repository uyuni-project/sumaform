include:
  - default

firewall:
  pkg.installed:
    - name: SuSEfirewall2
    - require:
      - sls: default

{% if grains['for_development_only'] %}

disable-firewall:
  service.dead:
    - name: SuSEfirewall2
    - enable: False

{% else %}

configure-firewall:
  file.replace:
    - name: /etc/sysconfig/SuSEfirewall2
    - pattern: |
        ^FW_SERVICES_EXT_TCP
    - repl: |
        FW_SERVICES_EXT_TCP="http https ssh xmpp-client xmpp-server tftp 1521 5432 4505 4506"
    - append_if_not_found: True
    - require:
      - pkg: firewall

{% endif %}

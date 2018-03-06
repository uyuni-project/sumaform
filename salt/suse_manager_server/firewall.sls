include:
  - default

firewall:
  pkg.installed:
    - name: SuSEfirewall2
    - require:
      - sls: default

{% if grains.get('disable_firewall') | default(true, true) %}

disable_firewall:
  service.dead:
    - name: SuSEfirewall2
    - enable: False

{% else %}

firewall_configuration:
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

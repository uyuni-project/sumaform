include:
  - default

firewall:
  pkg.installed:
    - name: SuSEfirewall2
    - require:
      - sls: default

{% if grains['for_development_only'] %}

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
        FW_SERVICES_EXT_TCP="postgresql ssh"
    - append_if_not_found: True
    - require:
      - pkg: firewall

{% endif %}

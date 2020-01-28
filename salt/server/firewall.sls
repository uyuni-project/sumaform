include:
  - default

firewall:
  pkg.installed:
{% if grains.get('osmajorrelease', None)|int() == 15 %}
    - name: firewalld
{% else %}
    - name: SuSEfirewall2
{% endif %}
    - require:
      - sls: default

{% if grains.get('disable_firewall') %}

disable_firewall:
  service.dead:
{% if grains.get('osmajorrelease', None)|int() == 15 %}
    - name: firewalld
{% else %}
    - name: SuSEfirewall2
{% endif %}
    - enable: False

{% else %}

firewall_configuration:
{% if grains.get('osmajorrelease', None)|int() == 15 %}
  file.managed:
    - name: /etc/firewalld/zones/public.xml
    - source: salt://server/firewalld_public.xml
{% else %}
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

{% endif %}

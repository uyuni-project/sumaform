
{% if grains.get('disable_firewall') | default(true, true)  %}

disable_firewall:
  service.dead:
{% if grains.get('osmajorrelease', None)|int() == 15 %}
    - name: firewalld
{% else %}
    - name: SuSEfirewall2
{% endif %}
    - enable: False
{% endif %}

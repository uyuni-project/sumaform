{% if grains['os_family'] == 'Suse' %}

SuSEfirewall2:
  service.dead:
    - enable: False

{% elif grains['os'] == 'Fedora' %}

firewalld:
  service.dead:
    - enable: False

{% endif %}

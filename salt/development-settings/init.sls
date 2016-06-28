include:
  - .firewall

{% if grains['role'] == 'suse-manager-server' or grains['role'] == 'spacewalk-server' %}
  - .java-debugging
{% endif %}

{% if grains['role'] == 'suse-manager-server' %}
  - .rhn

{% if grains['database'] == 'postgres' %}
  - .postgres
{% endif %}

{% endif %}

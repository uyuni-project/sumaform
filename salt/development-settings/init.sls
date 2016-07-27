{% if grains['role'] == 'suse-manager-server' or grains['role'] == 'spacewalk-server' %}
include:
  - .java-debugging
{% endif %}

{% if grains['role'] == 'suse-manager-server' %}
  - .rhn
  - .iss

{% if grains['database'] == 'postgres' %}
  - .postgres
{% endif %}

{% endif %}

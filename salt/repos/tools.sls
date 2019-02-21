{% if grains['os'] == 'SUSE' and (
      grains.get('role') in ['controller', 'grafana', 'mirror'] or
      grains.get('evil_minion_count') or
      grains.get('monitored') or
      grains.get('pts')
) %}

{% if grains['osrelease'] == '11.4' %}
{% set path = 'SLE_11_SP4' %}
{% elif grains['osrelease'] == '12' %}
{% set path = 'SLE_12' %}
{% elif grains['osrelease'] == '12.1' %}
{% set path = 'SLE_12_SP1' %}
{% elif grains['osrelease'] == '12.2' %}
{% set path = 'SLE_12_SP2' %}
{% elif grains['osrelease'] == '12.3' %}
{% set path = 'SLE_12_SP3' %}
{% elif grains['osrelease'] == '12.4' %}
{% set path = 'SLE_12_SP4' %}
{% elif grains['osrelease'] == '15.1' %}
{% set path = 'SLE_15_SP1' %}
{% elif grains['osrelease'] == '42.3' %}
{% set path = 'openSUSE_Leap_42.3' %}
{% endif %}

tools_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/repodata/repomd.xml.key

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

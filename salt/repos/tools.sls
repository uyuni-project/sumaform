{% if grains['os'] == 'SUSE' and (
      'controller' in grains.get('roles') or
      'grafana' in grains.get('roles') or
      'mirror' in grains.get('roles') or
      grains.get('evil_minion_count') or
      grains.get('monitored')
) %}

{% if grains['osfullname'] == 'Leap' %}
{% set path = 'openSUSE_Leap_' + grains['osrelease'] %}
{% endif %}

{% if grains['osfullname'] != 'Leap' %}
{% if grains['osrelease'] == '12.5' %}
{% set path = 'SLE_12_SP5' %}
{% elif grains['osrelease'] == '15.2' %}
{% set path = 'SLE_15_SP2' %}
{% elif grains['osrelease'] == '15.3' %}
{% set path = 'SLE_15_SP3' %}
{% elif grains['osrelease'] == '15.4' %}
{% set path = 'SLE_15_SP4' %}
{% elif grains['osrelease'] == '15.5' %}
{% set path = 'SLE_15_SP5' %}
{% elif grains['osrelease'] == '15.6' %}
{% set path = 'SLE_15_SP6' %}
{% endif %}
{% endif %}

tools_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/repodata/repomd.xml.key

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

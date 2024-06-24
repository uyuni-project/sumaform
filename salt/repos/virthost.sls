{% if 'virthost' in grains.get('roles') %}

{% if grains['osfullname'] == 'SLES' %}

{% if grains['osrelease'] == '15' %}
{% set sle_version_path = '15' %}
{% elif grains['osrelease'] == '15.1' %}
{% set sle_version_path = '15-SP1' %}
{% elif grains['osrelease'] == '15.2' %}
{% set sle_version_path = '15-SP2' %}
{% elif grains['osrelease'] == '15.3' %}
{% set sle_version_path = '15-SP3' %}
{% elif grains['osrelease'] == '15.4' %}
{% set sle_version_path = '15-SP4' %}
{% elif grains['osrelease'] == '15.5' %}
{% set sle_version_path = '15-SP5' %}
{% elif grains['osrelease'] == '15.6' %}
{% set sle_version_path = '15-SP6' %}
{% endif %}

module_server_applications_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Server-Applications/{{ sle_version_path }}/{{ grains.get("cpuarch") }}/product/
    - refresh: True

module_server_applications_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Server-Applications/{{ sle_version_path }}/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

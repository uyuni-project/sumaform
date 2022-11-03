{% if 'minion' in grains.get('roles') and grains.get('testsuite') | default(false, true) and grains['osfullname'] == 'SLES' and not grains.get('sles_registration_code') %}

{% if '15' in grains['osrelease'] %}

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
{% endif %}

{% endif %}


{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
default_nop:
  test.nop: []

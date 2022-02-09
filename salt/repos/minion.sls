{% if 'minion' in grains.get('roles') and grains.get('testsuite') | default(false, true) and grains['osfullname'] == 'SLES' %}

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
{% endif %}

{% if '4.0-nightly' in grains.get('product_version') %}
python2_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Python2/{{ sle_version_path }}/x86_64/product/
    - refresh: True

python2_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Python2/{{ sle_version_path }}/x86_64/update/
    - refresh: True
{% endif %}

{% endif %}


{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
default_nop:
  test.nop: []

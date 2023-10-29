{% if 'build_host' in grains.get('roles') and grains.get('testsuite') | default(false, true) and grains['osfullname'] == 'SLES' and not grains.get('sles_registration_code')%}

{% if '12' in grains['osrelease'] %}
containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/12/x86_64/product/
    - refresh: True

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/12/x86_64/update/
    - refresh: True

{% endif %}

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

cloud_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Public-Cloud/{{ sle_version_path }}/x86_64/product/
    - refresh: True

cloud_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Public-Cloud/{{ sle_version_path }}/x86_64/update/
    - refresh: True

containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/{{ sle_version_path }}/x86_64/product/
    - refresh: True

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/{{ sle_version_path }}/x86_64/update/
    - refresh: True

devel_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Development-Tools/{{ sle_version_path }}/x86_64/product/
    - refresh: True

devel_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Development-Tools/{{ sle_version_path }}/x86_64/update/
    - refresh: True

{# The following "SLE-Module-Desktop-Applications" channel is required by "SLE-Module-Development-Tools" module #}
desktop_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Desktop-Applications/{{ sle_version_path }}/x86_64/product/
    - refresh: True

{# The following "SLE-Module-Desktop-Applications" channel is required by "SLE-Module-Development-Tools" module #}
desktop_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Desktop-Applications/{{ sle_version_path }}/x86_64/update/
    - refresh: True

{% endif %}


{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

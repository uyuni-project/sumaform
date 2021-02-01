{% if 'minion' in grains.get('roles') and grains.get('testsuite') | default(false, true) and grains['osfullname'] == 'SLES' %}

{% if '12' in grains['osrelease'] %}
containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/12/x86_64/product/

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/12/x86_64/update/

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
{% endif %}

containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/{{ sle_version_path }}/x86_64/product/

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/{{ sle_version_path }}/x86_64/update/

devel_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Development-Tools/{{ sle_version_path }}/x86_64/product/

devel_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Development-Tools/{{ sle_version_path }}/x86_64/update/

{# The following "SLE-Module-Desktop-Applications" channel is required by "SLE-Module-Development-Tools" module #}
desktop_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Desktop-Applications/{{ sle_version_path }}/x86_64/product/

{# The following "SLE-Module-Desktop-Applications" channel is required by "SLE-Module-Development-Tools" module #}
desktop_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Desktop-Applications/{{ sle_version_path }}/x86_64/update/

{% if '3.2-nightly' in grains.get('product_version') or '4.0-nightly' in grains.get('product_version') %}
python2_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Python2/{{ sle_version_path }}/x86_64/product/

python2_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Python2/{{ sle_version_path }}/x86_64/update/
{% endif %}

{% endif %}


{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
default_nop:
  test.nop: []

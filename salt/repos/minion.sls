{% if grains.get('role') == 'minion' and grains.get('testsuite') | default(false, true) and grains['os'] == 'SUSE' %}

{% if '12' in grains['osrelease'] %}
containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/12/x86_64/product/

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/12/x86_64/update/

{% endif %}

{% if '15' in grains['osrelease'] %}
containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/15/x86_64/product/

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/15/x86_64/update/
{% endif %}


{% endif %}

{% if grains.get('evil_minion_count') and grains['os'] == 'SUSE' %}
tools_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/sumaform:/tools/{{path}}/repodata/repomd.xml.key
{% endif %}

# HACK: work around #10852
default_nop:
  test.nop: []

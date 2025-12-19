{# This state setup OS Vendor repositories #}

{% if grains['os'] == 'SUSE' %}
{% if grains['osfullname'] == 'Leap' %}
os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/distribution/leap/{{ grains['osrelease'] }}/repo/oss/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/update/leap/{{ grains['osrelease'] }}/oss/
    - refresh: True

{% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}
sle_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/update/leap/{{ grains['osrelease'] }}/sle/
    - refresh: True

backports_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/update/leap/{{ grains['osrelease'] }}/backports/
    - refresh: True
{% endif %} {# grains['osfullname'] == 'Leap' #}


{% elif grains['osfullname'] == 'SLES' %}

{% if '12' in grains['osrelease'] %}
{% if not grains.get('sles_registration_code') %} ## Skip if SCC support
{% if grains['osrelease'] == '12.5' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP5/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP5/{{ grains.get("cpuarch") }}/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP5-LTSS/{{ grains.get("cpuarch") }}/update/

{% endif %}
{% endif %} ## End skip if SCC support

{% endif %} {# '12' in grains['osrelease'] #}

{% if '15' in grains['osrelease'] %}
{% if not ( grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code') or 'paygo' in grains.get('product_version') | default('', true)) %} ## Skip if SCC support or PAYG

{% if '15.2' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP2/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP2/{{ grains.get("cpuarch") }}/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SLES/15-SP2-LTSS/{{ grains.get("cpuarch") }}/update/

{% elif '15.3' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP3/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP3/{{ grains.get("cpuarch") }}/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SLES/15-SP3-LTSS/{{ grains.get("cpuarch") }}/update/

{% elif '15.4' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP4/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP4/{{ grains.get("cpuarch") }}/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SLES/15-SP4-LTSS/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% elif '15.5' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP5/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP5/{{ grains.get("cpuarch") }}/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SLES/15-SP5-LTSS/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% elif '15.6' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP6/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP6/{{ grains.get("cpuarch") }}/update/
    - refresh: True

# uncomment when it goes LTSS
#os_ltss_repo:
#  pkgrepo.managed:
#    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de", true) }}/ibs/SUSE/Updates/SLE-Product-SLES/15-SP6-LTSS/{{ grains.get("cpuarch") }}/update/
#    - refresh: True

{% elif '15.7' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP7/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP7/{{ grains.get("cpuarch") }}/update/
    - refresh: True

# uncomment when it goes LTSS
#os_ltss_repo:
#  pkgrepo.managed:
#    - baseurl: http://{{ grains.get("mirror") | default("dist.suse.de", true) }}/ibs/SUSE/Updates/SLE-Product-SLES/15-SP7-LTSS/{{ grains.get("cpuarch") }}/update/
#    - refresh: True

{% endif %} {# '15.7' == grains['osrelease'] #}

{% endif %} {# '15' in grains['osrelease'] #}
{% endif %} {# Skip if SCC support or PAYG #}


{% endif %}{# grains['osfullname'] == 'SLES' #}
{% endif %} {# grains['os'] == 'SUSE' #}

{# WORKAROUND: see github:saltstack/salt#10852 #}
{{ sls }}_nop:
  test.nop: []

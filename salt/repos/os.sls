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

{% if grains['osrelease'] == '11.4' %}
os_pool_repo:
  pkgrepo.managed:
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-Pool/sle-11-x86_64/
    {% else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/zypp-patches.suse.de/x86_64/update/SLE-SERVER/11-SP4-POOL/
    {% endif %}
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-Updates/sle-11-x86_64/
    {% else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4/x86_64/update/
    {% endif %}
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-LTSS-Updates/sle-11-x86_64/
    {% else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4-LTSS/x86_64/update/
    {% endif %}
    - refresh: True
{% endif %} {# grains['osrelease'] == '11.4' #}


{% if '12' in grains['osrelease'] %}
{% if not grains.get('sles_registration_code') %} ## Skip if SCC support
{% if grains['osrelease'] == '12.3' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP3/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP3/x86_64/update/
    - refresh: True

{% elif grains['osrelease'] == '12.4' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP4/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP4/x86_64/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP4-LTSS/x86_64/update/
    - refresh: True

{% elif grains['osrelease'] == '12.5' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP5/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP5/x86_64/update/
    - refresh: True

# uncomment when it goes LTSS
# os_ltss_repo:
#   pkgrepo.managed:
#           - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP5-LTSS/x86_64/update/

{% endif %}
{% endif %} ## End skip if SCC support

{% endif %} {# '12' in grains['osrelease'] #}

{% if '15' in grains['osrelease'] %}
{% if not ( grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code') or 'paygo' in grains.get('product_version') | default('', true)) %} ## Skip if SCC support or PAYG

{% if '15' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15/x86_64/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SLES/15-LTSS/x86_64/update/
    - refresh: True

{% elif '15.1' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP1/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP1/x86_64/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SLES/15-SP1-LTSS/x86_64/update/
    - refresh: True

{% elif '15.2' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP2/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP2/x86_64/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE/Updates/SLE-Product-SLES/15-SP2-LTSS/x86_64/update/

{% elif '15.3' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP3/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP3/{{ grains.get("cpuarch") }}/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE/Updates/SLE-Product-SLES/15-SP3-LTSS/{{ grains.get("cpuarch") }}/update/

{% elif '15.4' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP4/{{ grains.get("cpuarch") }}/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP4/{{ grains.get("cpuarch") }}/update/
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Product-SLES/15-SP4-LTSS/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% elif '15.5' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP5/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP5/x86_64/update/
    - refresh: True

# uncomment when it goes LTSS
#os_ltss_repo:
#  pkgrepo.managed:
#    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE/Updates/SLE-Product-SLES/15-SP5-LTSS/x86_64/update/
#    - refresh: True

{% elif '15.6' == grains['osrelease'] %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP6/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP6/x86_64/update/
    - refresh: True

# uncomment when it goes LTSS
#os_ltss_repo:
#  pkgrepo.managed:
#    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE/Updates/SLE-Product-SLES/15-SP6-LTSS/x86_64/update/
#    - refresh: True

{% endif %} {# '15.6' == grains['osrelease'] #}

{% endif %} {# '15' in grains['osrelease'] #}
{% endif %} {# Skip if SCC support or PAYG #}


{% endif %}{# grains['osfullname'] == 'SLES' #}
{% endif %} {# grains['os'] == 'SUSE' #}


{% if grains['os_family'] == 'RedHat' %}

{% set release = grains.get('osmajorrelease', None)|int() %}

{% if release == 9 %}
{% if salt['file.search']('/etc/os-release', 'Liberty') %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://rmt.scc.suse.de/repo/SUSE/Updates/SLL/9/x86_64/update
    - refresh: True

os_as_pool_repo:
  pkgrepo.managed:
    - baseurl: http://rmt.scc.suse.de/repo/SUSE/Updates/SLL-AS/9/x86_64/update
    - refresh: True

os_updates_repo:
  pkgrepo.managed:
    - baseurl: https://rmt.scc.suse.de/repo/SUSE/Updates/SLL/9/x86_64/update/?credentials=SUSE_Liberty_Linux_x86_64
    - refresh: True

os_as_updates_repo:
  pkgrepo.managed:
    - baseurl: https://rmt.scc.suse.de/repo/SUSE/Updates/SLL-AS/9/x86_64/update/?credentials=SUSE_Liberty_Linux_x86_64
    - refresh: True

os_cb_updates_repo:
  pkgrepo.managed:
    - baseurl: https://rmt.scc.suse.de/repo/SUSE/Updates/SLL-CB/9/x86_64/update/?credentials=SUSE_Liberty_Linux_x86_64
    - refresh: True
{% endif %} {# salt['file.search']('/etc/os-release', 'Liberty') #}
{% endif %} {# release == 9 #}

{% endif %} {# grains['os_family'] == 'RedHat' #}


{# WORKAROUND: see github:saltstack/salt#10852 #}
{{ sls }}_nop:
  test.nop: []

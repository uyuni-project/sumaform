{% for keypath in grains.get('gpg_keys') | default([], true) %}
{% set keyname =  salt['file.basename'](keypath)  %}
gpg_key_copy_{{ keypath }}:
  file.managed:
    - name: /tmp/{{ keyname }}
    - source: salt://{{ keypath }}
install_{{ keypath }}:
  cmd.wait:
    - name: rpm --import /tmp/{{ salt['file.basename'](keypath) }}
    - watch:
      - file: /tmp/{{ keyname }}
{% endfor %}

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
{% endif %}

{% if not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles')) %}
{% if grains.get('product_version') and 'uyuni-master' in grains.get('product_version') | default('', true) %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/repodata/repomd.xml.key
    - priority: 98

{% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}
# Needed because in sles15SP3 and opensuse 15.3 and higher firewalld will replace this package.
# But the tools_update_repo priority don't allow to cope with the Obsoletes option from firewalld
lock_firewalld_prometheus_config_leap_cmd:
   cmd.run:
     - name: zypper addlock firewalld-prometheus-config
{% endif %}

{% elif not grains.get('product_version') or not 'uyuni-pr' in grains.get('product_version') | default('', true) %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/
    - refresh: True
    - priority: 98
{% endif %}
{% endif %} {# not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles')) #}

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

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/11-SP4:/x86_64/update/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/11-SP4:/x86_64/update/repodata/repomd.xml.key
{% endif %}

tools_pool_repo:
  pkgrepo.managed:
    {% if grains.get('mirror') %}
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-SUSE-Manager-Tools-Beta/sle-11-x86_64/
    {% else %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-SUSE-Manager-Tools/sle-11-x86_64/
    {% endif %}
    {% else %}
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4-CLIENT-TOOLS-BETA/x86_64/update/
    {% else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4-CLIENT-TOOLS/x86_64/update/
    {% endif %}
    {% endif %}
    - refresh: True

# SLE11 will not get Head/4.3 client tools. Submissions to be done from 4.2 until it's EoL from a SUSE Manager POV, and removed completely from sumaform
{% if 'nightly' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.2:/SLE11-SUSE-Manager-Tools/images/repo/SLE-11-SP4-CLIENT-TOOLS-ia64-ppc64-s390x-x86_64-Media1/suse/
    - refresh: True
    - priority: 98
{% endif %}

{% endif %} {# grains['osrelease'] == '11.4' #}


{% if '12' in grains['osrelease'] %}
{% if grains['osrelease'] == '12.3' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP3/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP3/x86_64/update/
    - refresh: True

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP3:/x86_64/update/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP3:/x86_64/update/repodata/repomd.xml.key
{% endif %}

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

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP4:/x86_64/update/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP4:/x86_64/update/repodata/repomd.xml.key
{% endif %}
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

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP5:/x86_64/update/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP5:/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% endif %}

{% if not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles')) and not grains.get('sles_registration_code') %}
{% if not grains.get('product_version') or not grains.get('product_version').startswith('uyuni-') %}
tools_pool_repo:
  pkgrepo.managed:
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/12-BETA/x86_64/product/
    {% else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/12/x86_64/product/
    {% endif %}
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/12-BETA/x86_64/update/
    {% else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/12/x86_64/update/
    {% endif %}
    - refresh: True
{% else %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE12-Uyuni-Client-Tools/SLE_12/
    - refresh: True
    - priority: 98
{% endif %}

{% if 'nightly' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    {# WORKAROUND: Change Head to 4.3 when Devel:Galaxy:Manager:4.3 is ready #}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-POOL-x86_64-Media1/
    - refresh: True
    - priority: 98

{% elif 'head' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-Beta-POOL-x86_64-Media1/
    - refresh: True
    - priority: 98

{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE12-Uyuni-Client-Tools/SLE_12/
    - refresh: True
    - priority: 98
{% endif %}

{% endif %} {# not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles')) #}
{% endif %} {# '12' in grains['osrelease'] #}


{% if '15' in grains['osrelease'] %}
{% if (not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles'))) %}
{% if not grains.get('product_version') or not grains.get('product_version').startswith('uyuni-') %}
tools_pool_repo:
  pkgrepo.managed:
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15-BETA/x86_64/product/
    {% else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15/x86_64/product/
    {% endif %}
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15-BETA/x86_64/update/
    {% else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15/x86_64/update/
    {% endif %}
    - refresh: True
{% else %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True
    - priority: 98
{% endif %}

{% if 'nightly' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
  {# WORKAROUND: Change Head to 4.3 when Devel:Galaxy:Manager:4.3 is ready #}
  - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
  - refresh: True
  - priority: 98

{% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}
# Needed because in sles15SP3 and opensuse 15.3 and higher firewalld will replace this package.
# But the tools_update_repo priority don't allow to cope with the Obsoletes option from firewalld
lock_firewalld_prometheus_config_cmd:
   cmd.run:
     - name: zypper addlock firewalld-prometheus-config
{% endif %}

{% elif 'head' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
    - refresh: True
    - priority: 98

{% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}
# Needed because in sles15SP3 and opensuse 15.3 and higher firewalld will replace this package.
# But the tools_update_repo priority don't allow to cope with the Obsoletes option from firewalld
lock_firewalld_prometheus_config_cmd:
   cmd.run:
     - name: zypper addlock firewalld-prometheus-config
{% endif %}

{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True
    - priority: 98

{% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}
# Needed because in sles15SP3 and opensuse 15.3 and higher firewalld will replace this package.
# But the tools_update_repo priority don't allow to cope with the Obsoletes option from firewalld
lock_firewalld_prometheus_config_cmd:
   cmd.run:
     - name: zypper addlock firewalld-prometheus-config
{% endif %}

{% endif %}


{% endif %} {# not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles')) #}
{% endif %} {# '15' in grains['osrelease'] #}

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

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-Module-Basesystem:/15:/x86_64/update/
    - refresh: True
    - gpgcheck: 1
{% endif %}
{% endif %} {# '15' == grains['osrelease'] #}

{% if '15.1' == grains['osrelease'] and not ( grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code')) %}
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

{% endif %} {# '15.1' == grains['osrelease'] #}

{% if '15.2' == grains['osrelease'] and not ( grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code')) %}
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

{% endif %} {# '15.2' == grains['osrelease'] #}

{% if '15.3' == grains['osrelease'] and not ( grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code')) %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP3/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP3/x86_64/update/
    - refresh: True

# uncomment when it goes LTSS
# os_ltss_repo:
#   pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE/Updates/SLE-Product-SLES/15-SP3-LTSS/x86_64/update/

{% endif %} {# '15.3' == grains['osrelease'] #}

{% if '15.4' == grains['osrelease'] and not ( grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code') ) %}

{# WORKAROUND: Moving target, only until SLE15SP4 GA is ready. Remove this block when we start using GA #}
{% if not 'beta' in grains['product_version'] %}
os_movingtarget_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/SLE-15-SP4:/GA:/TEST/images/repo/SLE-15-SP4-Module-Basesystem-POOL-x86_64-Media1/
    - refresh: True
{% endif %}
{# WORKAROUND: Moving target, only until SLE15SP4 GA is ready #}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP4/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP4/x86_64/update/
    - refresh: True

# Already made in advance but empty now:
os_ltss_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE/Updates/SLE-Product-SLES/15-SP4-LTSS/x86_64/update/
    - refresh: True

{% endif %} {# '15.4' == grains['osrelease'] #}

{% endif %} {# grains['osfullname'] == 'SLES' #}

install_recommends:
  file.comment:
    - name: /etc/zypp/zypp.conf
    - regex: solver.onlyRequires =

{% endif %}

{% if grains['os_family'] == 'RedHat' %}

{% set release = grains.get('osmajorrelease', None)|int() %}

galaxy_key:
  file.managed:
    - name: /tmp/galaxy.key
    - source: salt://default/gpg_keys/galaxy.key
  cmd.wait:
    - name: rpm --import /tmp/galaxy.key
    - watch:
      - file: galaxy_key
{% if 'uyuni-master' in grains.get('product_version', '') or 'uyuni-released' in grains.get('product_version', '') or 'uyuni-pr' in grains.get('product_version', '') %}
uyuni_key:
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key
{% endif %}

{% if not grains.get('product_version') or not grains.get('product_version').startswith('uyuni-') %}
tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    {% if release >= 8 %}
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/RES/{{ release }}-CLIENT-TOOLS-BETA/x86_64/product/
    {% else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/RES/{{ release }}-CLIENT-TOOLS/x86_64/product/
    {% endif %}
    {% elif grains.get('mirror') %}
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/RES{{ release }}-SUSE-Manager-Tools-Beta/x86_64/
    {% else %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/RES{{ release }}-SUSE-Manager-Tools/x86_64/
    {% endif %}
    {% else %}
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://download.suse.de/ibs/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS-BETA/x86_64/update/
    {% else %}
    # Amazon Linux support
    {% if release == 2 %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/RES/7-CLIENT-TOOLS/x86_64/product/
    {% else %}
    - baseurl: http://download.suse.de/ibs/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS/x86_64/update/
    {% endif %}
    {% endif %}
    {% endif %}
    - refresh: True
    - require:
      - cmd: galaxy_key

{% if release >= 8 %}
tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    {% if 'beta' in grains.get('product_version') | default('', true) %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS-BETA/x86_64/update/
    {% else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS/x86_64/update/
    {% endif %}
    - refresh: True
    - require:
      - cmd: galaxy_key
{% endif %}

suse_res7_key:
  file.managed:
    - name: /tmp/suse_res7.key
    - source: salt://default/gpg_keys/suse_res7.key
  cmd.wait:
    - name: rpm --import /tmp/suse_res7.key
    - watch:
      - file: suse_res7_key

suse_res6_key:
  file.managed:
    - name: /tmp/suse_res6.key
    - source: salt://default/gpg_keys/suse_res6.key
  cmd.wait:
    - name: rpm --import /tmp/suse_res6.key
    - watch:
      - file: suse_res6_key
{% else %}

{% set centos_client_tool_prefix = 'EL' %}
{% if release < 8 %}
{% set centos_client_tool_prefix = 'CentOS' %}
{% endif %}

tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/{{centos_client_tool_prefix}}{{ release }}-Uyuni-Client-Tools/{{centos_client_tool_prefix}}_{{ release }}/
    - refresh: True
    - priority: 98
    - require:
      - cmd: uyuni_key
{% endif %}

{% if 'nightly' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    {# WORKAROUND: Change Head to 4.3 when Devel:Galaxy:Manager:4.3 is ready #}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/RES{{ release }}-SUSE-Manager-Tools/SUSE_RES-{{ release }}_Update_standard/
    - refresh: True
    - require:
      - cmd: galaxy_key
{% elif 'head' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/RES{{ release }}-SUSE-Manager-Tools/SUSE_RES-{{ release }}_Update_standard/
    - refresh: True
    - priority: 98
    - require:
      - cmd: galaxy_key
{% elif 'uyuni-master' in grains.get('product_version', '') or 'uyuni-pr' in grains.get('product_version', '') %}

{% set centos_client_tool_prefix = 'EL' %}
{% if release < 8 %}
{% set centos_client_tool_prefix = 'CentOS' %}
{% endif %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/{{centos_client_tool_prefix}}{{ release }}-Uyuni-Client-Tools/{{centos_client_tool_prefix}}_{{ release }}/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/{{centos_client_tool_prefix}}{{ release }}-Uyuni-Client-Tools/{{centos_client_tool_prefix}}_{{ release }}/repodata/repomd.xml.key
    - priority: 98
    - require:
      - cmd: uyuni_key
{% endif %}

clean_repo_metadata:
  cmd.run:
    - name: yum clean metadata

{% endif %} {# grains['os_family'] == 'RedHat' #}

{% if grains['os_family'] == 'Debian' and grains['os'] == 'Ubuntu' %}

{% set release = grains.get('osrelease', None) %}
{% set short_release = release | replace('.', '') %}

disable_apt_daily_timer:
  service.dead:
    - name: apt-daily.timer
    - enable: False

disable_apt_daily_upgrade_timer:
  service.dead:
    - name: apt-daily-upgrade.timer
    - enable: False

disable_apt_daily_service:
  service.dead:
    - name: apt-daily.service
    - enable: False

disable_apt_daily_upgrade_service:
  service.dead:
    - name: apt-daily-upgrade.service
    - enable: False

wait_until_apt_lock_file_unlock:
  cmd.run:
    - name: "test ! -f /var/lib/apt/lists/lock || ! lsof /var/lib/apt/lists/lock"
    - retry:
      - attempts: 10
      - interval: 5
      - until: True

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - file: /etc/apt/sources.list.d/tools_update_repo.list
# We only have one shared Client Tools repository, so we are using 4.3 for 4.2 annd 4.1
{% if 'nightly' in grains.get('product_version') | default('', true) %}
{# WORKAROUND: Change Head to 4.3 when Devel:Galaxy:Manager:4.3 is ready #}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/Ubuntu' + release + '-SUSE-Manager-Tools/xUbuntu_' + release %}
{% elif 'head' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/Ubuntu' + release + '-SUSE-Manager-Tools/xUbuntu_' + release %}
{% elif 'beta' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS-BETA/x86_64/update/' %}
{% elif '4.1-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
{% elif '4.2-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Master:/Ubuntu' + short_release + '-Uyuni-Client-Tools/xUbuntu_' + release %}
{% else %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Stable:/Ubuntu' + short_release + '-Uyuni-Client-Tools/xUbuntu_' + release %}
{% endif %}
    - refresh: True
    - name: deb {{ tools_repo_url }} /
    - key_url: {{ tools_repo_url }}/Release.key

tools_update_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/tools_update_repo
{% if 'head' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:Head:Ubuntu{{ release }}-SUSE-Manager-Tools
            Pin-Priority: 800
{% elif 'nightly' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:Head:Ubuntu{{ release }}-SUSE-Manager-Tools {# WORKAROUND: Change Head to 4.3 when Devel:Galaxy:Manager:4.3 is ready #}
            Pin-Priority: 800
{% elif '4.1-released' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=SUSE:Updates:Ubuntu:{{ release }}-CLIENT-TOOLS:x86_64:update
            Pin-Priority: 800
{% elif '4.2-released' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=SUSE:Updates:Ubuntu:{{ release }}-CLIENT-TOOLS:x86_64:update
            Pin-Priority: 800
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=systemsmanagement:Uyuni:Master:Ubuntu{{ short_release }}-Uyuni-Client-Tools
            Pin-Priority: 800
{% elif 'uyuni-released' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=systemsmanagement:Uyuni:Stable:Ubuntu{{ short_release }}-Uyuni-Client-Tools
            Pin-Priority: 800
{% endif %}
{% endif %}

{% if grains['os_family'] == 'Debian' %}
remove_no_install_recommends:
  file.absent:
    - name: /etc/apt/apt.conf.d/00InstallRecommends
{% endif %}

{# WORKAROUND: see github:saltstack/salt#10852 #}
{{ sls }}_nop:
  test.nop: []

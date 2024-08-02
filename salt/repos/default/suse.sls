# Defines default repositories for SUSE family of distros

{% set release = grains.get('osrelease', None) %}
{% set version = grains.get('product_version', '') %}
{% set scc_support = (grains.get('server_registration_code') or grains.get('proxy_registration_code')
  or grains.get('sles_registration_code') or 'paygo' in version) %}
{% set is_srv_or_pxy = grains.get('roles') and ('server' in grains.get('roles') or 'proxy' in grains.get('roles')
  or 'server_containerized' in grains.get('roles') or 'proxy_containerized' in grains.get('roles')) %}

{% if grains['osfullname'] == 'Leap' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/distribution/leap/{{ release }}/repo/oss/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/update/leap/{{ release }}/oss/
    - refresh: True

  {% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}

sle_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/update/leap/{{ release }}/sle/
    - refresh: True

backports_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/update/leap/{{ release }}/backports/
    - refresh: True

  {% endif %}

  {% if not is_srv_or_pxy %}
    {% if version and not version.startswith('uyuni-') %}

tools_pool_repo:
  pkgrepo.managed:
    {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15-BETA/x86_64/product/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15/x86_64/product/
    {%- endif %}
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15-BETA/x86_64/update/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15/x86_64/update/
    {%- endif %}
    - refresh: True

    {% elif version == 'uyuni-master' %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/repodata/repomd.xml.key

      {% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}

# Needed because in sles15SP3 and opensuse 15.3 and higher firewalld will replace this package.
# But the tools_update_repo priority don't allow to cope with the Obsoletes option from firewalld
lock_firewalld_prometheus_config_leap_cmd:
   cmd.run:
     - name: zypper addlock firewalld-prometheus-config

      {% endif %}
    {% else %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/
    - refresh: True

    {% endif %}
  {% endif %}

{% elif grains['osfullname'] == 'SLES' %}
  {% if release == '11.4' %}

os_pool_repo:
  pkgrepo.managed:
    {%- if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-Pool/sle-11-x86_64/
    {%- else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/zypp-patches.suse.de/x86_64/update/SLE-SERVER/11-SP4-POOL/
    {%- endif %}
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    {%- if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-Updates/sle-11-x86_64/
    {%- else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4/x86_64/update/
    {%- endif %}
    - refresh: True

os_ltss_repo:
  pkgrepo.managed:
    {%- if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-LTSS-Updates/sle-11-x86_64/
    {%- else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4-LTSS/x86_64/update/
    {%- endif %}
    - refresh: True

tools_pool_repo:
  pkgrepo.managed:
    {%- if grains.get('mirror') %}
      {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-SUSE-Manager-Tools-Beta/sle-11-x86_64/
      {%- else %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-SUSE-Manager-Tools/sle-11-x86_64/
      {%- endif %}
    {%- else %}
      {%- if 'beta' in version %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4-CLIENT-TOOLS-BETA/x86_64/update/
      {%- else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4-CLIENT-TOOLS/x86_64/update/
      {%- endif %}
    {%- endif %}
    - refresh: True

    # SLE11 will not get Head/4.3 client tools. Submissions to be done from 4.2 until it's EoL from a SUSE Manager POV, and removed completely from sumaform
    {% if 'nightly' in version %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.2:/SLE11-SUSE-Manager-Tools/images/repo/SLE-11-SP4-CLIENT-TOOLS-ia64-ppc64-s390x-x86_64-Media1/suse/
    - refresh: True
    - priority: 98

    {% endif %}
  {% elif '12' in release %}
    {% if not scc_support %}
      {% if release == '12.3' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP3/x86_64/product/
    - refresh: True

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP3/x86_64/update/
    - refresh: True

      {% elif release == '12.4' %}

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

      {% elif release == '12.5' %}

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
    {% endif %}

    {% if not is_srv_or_pxy %}
      {% if version.startswith('uyuni-') %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE12-Uyuni-Client-Tools/SLE_12/
    - refresh: True

      {% else %}

tools_pool_repo:
  pkgrepo.managed:
    {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/12-BETA/x86_64/product/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/12/x86_64/product/
    {%- endif %}
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/12-BETA/x86_64/update/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/12/x86_64/update/
    {%- endif %}
    - refresh: True

      {% endif %}
      {% if 'nightly' in version %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-POOL-x86_64-Media1/
    - refresh: True
    - priority: 98

      {% elif version == 'head' %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-Beta-POOL-x86_64-Media1/
    - refresh: True
    - priority: 98

      {% elif version == 'uyuni-master' %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE12-Uyuni-Client-Tools/SLE_12/
    - refresh: True
    - priority: 98

      {% endif %}
    {% endif %}
  {% elif '15' in release %}
    {% if not is_srv_or_pxy %}
      {% if version.startswith('uyuni-') %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True

      {% else %}

tools_pool_repo:
  pkgrepo.managed:
    {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15-BETA/{{ grains.get("cpuarch") }}/product/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15/{{ grains.get("cpuarch") }}/product/
    {%- endif %}
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15-BETA/{{ grains.get("cpuarch") }}/update/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15/{{ grains.get("cpuarch") }}/update/
    {%- endif %}
    - refresh: True

      {% endif %}
      {% if 'nightly' in version %}

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
  - refresh: True
  - priority: 98

        {% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}

# Needed because in sles15SP3 and opensuse 15.3 and higher firewalld will replace this package.
# But the tools_update_repo priority don't allow to cope with the Obsoletes option from firewalld
lock_firewalld_prometheus_config_cmd:
   cmd.run:
     - name: zypper addlock firewalld-prometheus-config

        {% endif %}
      {% elif 'head' in version %}

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
      {% elif 'uyuni-master' in version %}

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True

        {% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}

# Needed because in sles15SP3 and opensuse 15.3 and higher firewalld will replace this package.
# But the tools_update_repo priority don't allow to cope with the Obsoletes option from firewalld
lock_firewalld_prometheus_config_cmd:
   cmd.run:
     - name: zypper addlock firewalld-prometheus-config

        {% endif %}
      {% endif %}
    {% endif %}
  {% endif %} {# '15' in release #}

  {% if not scc_support %}
    {% if '15' == release %}

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

    {% elif '15.1' == release %}

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

    {% elif '15.2' == release %}

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

    {% elif '15.3' == release %}

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

    {% elif '15.4' == release %}

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

    {% elif '15.5' == release %}

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

    {% elif '15.6' == release %}

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

    {% endif %} {# '15.x' release #}
  {% endif %} {# not scc_support #}

{% elif grains['osfullname'] in ['SLE Micro', 'SL-Micro'] and not is_srv_or_pxy %}
  {% if version.startswith('uyuni-') %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/repodata/repomd.xml.key

  {% elif version == 'head' or version.startswith('5.0') %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools-For-Micro/5/x86_64/product/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools-For-Micro/5/x86_64/product/repodata/repomd.xml.key

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools-For-Micro/5/x86_64/update/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools-For-Micro/5/x86_64/update/repodata/repomd.xml.key

  {% endif %}
{% endif %}

install_recommends:
  file.comment:
    - name: /etc/zypp/zypp.conf
    - regex: ^solver.onlyRequires =.*
    {%- if grains['saltversioninfo'][0] >= 3005 %}
    - ignore_missing: True
    {%- endif %}
    - onlyif: grep ^solver.onlyRequires /etc/zypp/zypp.conf

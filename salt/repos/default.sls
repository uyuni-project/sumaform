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

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/update/leap/{{ grains['osrelease'] }}/oss/

{% if not grains.get('roles') or ('suse_manager_server' not in grains.get('roles') and 'suse_manager_proxy' not in grains.get('roles')) %}
{% if grains.get('product_version') and grains.get('product_version').startswith('uyuni-') %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/
    - priority: 98
{% endif %}
{% if grains.get('product_version') and 'uyuni-master' in grains.get('product_version') | default('', true) %}
tools_pool_repo_master:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/repodata/repomd.xml.key
    - priority: 98
{% endif %}
{% endif %} {# not grains.get('roles') or ('suse_manager_server' not in grains.get('roles') and 'suse_manager_proxy' not in grains.get('roles')) #}

{% elif grains['osfullname'] == 'SLES' %}

{% if grains['osrelease'] == '11.4' %}

os_pool_repo:
  pkgrepo.managed:
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-Pool/sle-11-x86_64/
    {% else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/zypp-patches.suse.de/x86_64/update/SLE-SERVER/11-SP4-POOL/
    {% endif %}

os_update_repo:
  pkgrepo.managed:
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-Updates/sle-11-x86_64/
    {% else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4/x86_64/update/
    {% endif %}

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/11-SP4:/x86_64/update/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/11-SP4:/x86_64/update/repodata/repomd.xml.key
{% endif %}

tools_pool_repo:
  pkgrepo.managed:
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/SLES11-SP4-SUSE-Manager-Tools/sle-11-x86_64/
    {% else %}
    - baseurl: http://euklid.nue.suse.com/mirror/SuSE/build-ncc.suse.de/SUSE/Updates/SLE-SERVER/11-SP4-CLIENT-TOOLS/x86_64/update/
    {% endif %}

{% if 'nightly' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.0:/SLE11-SUSE-Manager-Tools/images/repo/SLE-11-SP4-CLIENT-TOOLS-ia64-ppc64-s390x-x86_64-Media1/suse/
    - priority: 98

{% elif 'head' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SLE11-SUSE-Manager-Tools/images/repo/SLE-11-SP4-CLIENT-TOOLS-ia64-ppc64-s390x-x86_64-Media1/suse/
    - priority: 98

{% endif %}

{% endif %} {# grains['osrelease'] == '11.4' #}


{% if '12' in grains['osrelease'] %}
{% if grains['osrelease'] == '12' %}
os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12/x86_64/product/

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12/x86_64/update/

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12:/x86_64/update/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12:/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% elif grains['osrelease'] == '12.1' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP1/x86_64/product/

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP1/x86_64/update/

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP1:/x86_64/update/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP1:/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% elif grains['osrelease'] == '12.2' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP2/x86_64/product/

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP2/x86_64/update/

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP2:/x86_64/update/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP2:/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% elif grains['osrelease'] == '12.3' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP3/x86_64/product/

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP3/x86_64/update/

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP3:/x86_64/update/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP3:/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% elif grains['osrelease'] == '12.4' %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-SERVER/12-SP4/x86_64/product/

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-SERVER/12-SP4/x86_64/update/

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP4:/x86_64/update/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-SERVER:/12-SP4:/x86_64/update/repodata/repomd.xml.key
{% endif %}

{% endif %}

{% if not grains.get('roles') or ('suse_manager_server' not in grains.get('roles') and 'suse_manager_proxy' not in grains.get('roles')) %}
{% if not grains.get('product_version') or not grains.get('product_version').startswith('uyuni-') %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/12/x86_64/product/

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/12/x86_64/update/
{% else %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE12-Uyuni-Client-Tools/SLE_12/
    - priority: 98
{% endif %}

{% if 'nightly' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.0:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-POOL-x86_64-Media1/
    - priority: 98

{% elif 'head' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-Beta-POOL-x86_64-Media1/
    - priority: 98

{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE12-Uyuni-Client-Tools/SLE_12/
    - priority: 98
{% endif %}

{% endif %} {# not grains.get('roles') or ('suse_manager_server' not in grains.get('roles') and 'suse_manager_proxy' not in grains.get('roles')) #}
{% endif %} {# '12' in grains['osrelease'] #}


{% if '15' in grains['osrelease'] %}
{% if not grains.get('roles') or ('suse_manager_server' not in grains.get('roles') and 'suse_manager_proxy' not in grains.get('roles')) %}
{% if not grains.get('product_version') or not grains.get('product_version').startswith('uyuni-') %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15/x86_64/product/

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15/x86_64/update/
{% else %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - priority: 98
{% endif %}

{% if 'nightly' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.0:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
  - priority: 98
{% elif 'head' in grains.get('product_version') | default('', true) %}
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
    - priority: 98
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/
    - priority: 98
{% endif %}

{% endif %} {# not grains.get('roles') or ('suse_manager_server' not in grains.get('roles') and 'suse_manager_proxy' not in grains.get('roles')) #}
{% endif %} {# '15' in grains['osrelease'] #}

{% if '15' == grains['osrelease'] %}
os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15/x86_64/product/

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15/x86_64/update/

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/SUSE:/Maintenance:/Test:/SLE-Module-Basesystem:/15:/x86_64/update/
    - gpgcheck: 1
{% endif %}
{% endif %} {# '15' == grains['osrelease'] #}

{% if '15.1' == grains['osrelease'] %}
os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Basesystem/15-SP1/x86_64/product/

os_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Basesystem/15-SP1/x86_64/update/
{% endif %} {# '15.1' == grains['osrelease'] #}

{% endif %} {# grains['osfullname'] == 'SLES' #}

allow_vendor_changes:
  {% if grains['osfullname'] == 'Leap' %}
  file.managed:
    - name: /etc/zypp/vendors.d/opensuse
    - makedirs: True
    - contents: |
        [main]
        vendors = openSUSE,openSUSE Build Service,obs://build.suse.de/Devel:Galaxy,obs://build.opensuse.org
  {% else %}
  file.managed:
    - name: /etc/zypp/vendors.d/suse
    - makedirs: True
    - contents: |
        [main]
        vendors = SUSE,openSUSE Build Service,obs://build.suse.de/Devel:Galaxy,obs://build.opensuse.org
  {% endif %}

{% endif %}

{% if grains['os_family'] == 'RedHat' %}

galaxy_key:
  file.managed:
    - name: /tmp/galaxy.key
    - source: salt://default/gpg_keys/galaxy.key
  cmd.wait:
    - name: rpm --import /tmp/galaxy.key
    - watch:
      - file: galaxy_key
{% if 'uyuni-master' in grains.get('product_version') or 'uyuni-released' in grains.get('product_version') %}
uyuni_key:
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key
{% endif %}

{% if grains.get('osmajorrelease', None)|int() == 7 %}
{% if not grains.get('product_version') or not grains.get('product_version').startswith('uyuni-') %}
tools_pool_repo:
  pkgrepo.managed:
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/RES7-SUSE-Manager-Tools/x86_64/
    {% else %}
    - baseurl: http://download.suse.de/ibs/SUSE/Updates/RES/7-CLIENT-TOOLS/x86_64/update/
    {% endif %}
    - require:
      - cmd: galaxy_key

suse_res7_key:
  file.managed:
    - name: /tmp/suse_res7.key
    - source: salt://default/gpg_keys/suse_res7.key
  cmd.wait:
    - name: rpm --import /tmp/suse_res7.key
    - watch:
      - file: suse_res7_key
{% else %}
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/CentOS7-Uyuni-Client-Tools/CentOS_7/
    - priority: 98
    - require:
      - cmd: uyuni_key
{% endif %}

{% if 'head' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/RES7-SUSE-Manager-Tools/SUSE_RES-7_Update_standard/
    - priority: 98
    - require:
      - cmd: galaxy_key
{% elif 'nightly' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.0:/RES7-SUSE-Manager-Tools/SUSE_RES-7_Update_standard/
    - require:
      - cmd: galaxy_key
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/CentOS7-Uyuni-Client-Tools/CentOS_7/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/CentOS7-Uyuni-Client-Tools/CentOS_7/repodata/repomd.xml.key
    - priority: 98
    - require:
      - cmd: uyuni_key
{% endif %}
{% endif %} {# grains.get('osmajorrelease', None)|int() == 7 #}
{% endif %} {# grains['os_family'] == 'RedHat' #}

{% if grains['os_family'] == 'Debian' and grains['os'] == 'Ubuntu' %}
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

disable_apt_daily_wait:
  cmd.run:
    - name: systemd-run --property="After=apt-daily.service apt-daily-upgrade.service" --wait /bin/true

tools_update_repo:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/Ubuntu1804-Client-Tools.list
{% if 'head' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/Ubuntu18.04-SUSE-Manager-Tools/xUbuntu_18.04' %}
{% elif '4.0-nightly' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/4.0:/Ubuntu18.04-SUSE-Manager-Tools/xUbuntu_18.04' %}
{% elif '4.0-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs//SUSE/Updates/Ubuntu/18.04-CLIENT-TOOLS/x86_64/update/' %}
# We only have one shared Client Tools repository, so we are using 4.0 even for 3.2
{% elif '3.2-nightly' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/4.0:/Ubuntu18.04-SUSE-Manager-Tools/xUbuntu_18.04' %}
{% elif '3.2-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/SUSE/Updates/Ubuntu/18.04-CLIENT-TOOLS/x86_64/update/' %}
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Master:/Ubuntu1804-Uyuni-Client-Tools/xUbuntu_18.04' %}
{% elif 'uyuni-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Stable:/Ubuntu1804-Uyuni-Client-Tools/xUbuntu_18.04' %}
{% endif %}
    - name: deb {{ tools_repo_url }} /
    - key_url: {{ tools_repo_url }}/Release.key

tools_update_repo_raised_priority:
  file.append:
    - name: /etc/apt/preferences.d/Ubuntu1804-Client-Tools
    - unless:
      - ls /etc/apt/preferences.d/Ubuntu1804-Client-Tools
{% if 'head' in grains.get('product_version') | default('', true) %}
    - text: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:Head:Ubuntu18.04-SUSE-Manager-Tools
            Pin-Priority: 800
{% elif '4.0-nightly' in grains.get('product_version') | default('', true) %}
    - text: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:4.0:Ubuntu18.04-SUSE-Manager-Tools
            Pin-Priority: 800
{% elif '4.0-released' in grains.get('product_version') | default('', true) %}
    - text: |
            Package: *
            Pin: release l=SUSE:Updates:Ubuntu:18.04-CLIENT-TOOLS:x86_64:update
            Pin-Priority: 800
# We only have one shared Client Tools repository, so we are using 4.0 even for 3.2
{% elif '3.2-nightly' in grains.get('product_version') | default('', true) %}
    - text: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:4.0:Ubuntu18.04-SUSE-Manager-Tools
            Pin-Priority: 800
{% elif '3.2-released' in grains.get('product_version') | default('', true) %}
    - text: |
            Package: *
            Pin: release l=SUSE:Updates:Ubuntu:18.04-CLIENT-TOOLS:x86_64:update
            Pin-Priority: 800
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
    - text: |
            Package: *
            Pin: release l=systemsmanagement:Uyuni:Master:Ubuntu1804-Uyuni-Client-Tools
            Pin-Priority: 800
{% elif 'uyuni-released' in grains.get('product_version') | default('', true) %}
    - text: |
            Package: *
            Pin: release l=systemsmanagement:Uyuni:Stable:Ubuntu1804-Uyuni-Client-Tools
            Pin-Priority: 800
{% endif %}
{% endif %}

{% if grains['os_family'] == 'Debian' %}
remove_no_install_recommends:
  file.absent:
    - name: /etc/apt/apt.conf.d/00InstallRecommends
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

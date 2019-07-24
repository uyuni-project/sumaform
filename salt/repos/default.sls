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
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-{{ grains['osrelease'] }}-Pool.repo
    - source: salt://repos/repos.d/openSUSE-Leap-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-{{ grains['osrelease'] }}-Update.repo
    - source: salt://repos/repos.d/openSUSE-Leap-Update.repo
    - template: jinja
{% elif grains['osfullname'] == 'SLES' %}

{% if grains['osrelease'] == '11.4' %}

os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP4-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-11-SP4-x86_64-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP4-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-11-SP4-x86_64-Update.repo
    - template: jinja

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP4-x86_64-Test-Update.repo
    - source: salt://repos/repos.d/SLE-11-SP4-x86_64-Test-Update.repo
    - template: jinja
{% endif %}

tools_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-11-x86_64.repo
    - source: salt://repos/repos.d/SLE-Manager-Tools-SLE-11-x86_64.repo
    - template: jinja

{% if 'nightly' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_4.0_SLE-Manager-Tools-11-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_4.0_SLE-Manager-Tools-11-x86_64.repo
    - template: jinja

{% elif 'head' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-11-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-11-x86_64.repo
    - template: jinja

{% endif %}

{% endif %} {# grains['osrelease'] == '11.4' #}


{% if '12' in grains['osrelease'] %}
{% if grains['osrelease'] == '12' %}
os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-12-x86_64-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-12-x86_64-Update.repo
    - template: jinja

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-x86_64-Test-Update.repo
    - source: salt://repos/repos.d/SLE-12-x86_64-Test-Update.repo
    - template: jinja
{% endif %}

{% elif grains['osrelease'] == '12.1' %}

os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-12-SP1-x86_64-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-12-SP1-x86_64-Update.repo
    - template: jinja

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-x86_64-Test-Update.repo
    - source: salt://repos/repos.d/SLE-12-SP1-x86_64-Test-Update.repo
    - template: jinja
{% endif %}

{% elif grains['osrelease'] == '12.2' %}

os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP2-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-12-SP2-x86_64-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP2-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-12-SP2-x86_64-Update.repo
    - template: jinja

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP2-x86_64-Test-Update.repo
    - source: salt://repos/repos.d/SLE-12-SP2-x86_64-Test-Update.repo
    - template: jinja
{% endif %}

{% elif grains['osrelease'] == '12.3' %}

os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP3-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-12-SP3-x86_64-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP3-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-12-SP3-x86_64-Update.repo
    - template: jinja

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP3-x86_64-Test-Update.repo
    - source: salt://repos/repos.d/SLE-12-SP3-x86_64-Test-Update.repo
    - template: jinja
{% endif %}

{% elif grains['osrelease'] == '12.4' %}

os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP4-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-12-SP4-x86_64-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP4-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-12-SP4-x86_64-Update.repo
    - template: jinja

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP4-x86_64-Test-Update.repo
    - source: salt://repos/repos.d/SLE-12-SP4-x86_64-Test-Update.repo
    - template: jinja
{% endif %}

{% endif %}

{% if not grains.get('role') or not grains.get('role').startswith('suse_manager') %}
tools_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
    - template: jinja

tools_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
    - template: jinja

{% if 'nightly' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_4.0_SLE-Manager-Tools-12-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_4.0_SLE-Manager-Tools-12-x86_64.repo
    - template: jinja

{% elif ('head' in grains.get('product_version') | default('', true)) or ('test' in grains.get('product_version') | default('', true)) %}

tools_additional_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-12-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-12-x86_64.repo
    - template: jinja

{% endif %}

{% endif %} {# not grains.get('role') or not grains.get('role').startswith('suse_manager') #}
{% endif %} {# '12' in grains['osrelease'] #}


{% if '15' in grains['osrelease'] %}
{% if not grains.get('role') or not grains.get('role').startswith('suse_manager') %}

tools_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-15-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-Manager-Tools-SLE-15-x86_64-Pool.repo
    - template: jinja

tools_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-15-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-Manager-Tools-SLE-15-x86_64-Update.repo
    - template: jinja

{% if 'nightly' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_4.0_SLE-Manager-Tools-15-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_4.0_SLE-Manager-Tools-15-x86_64.repo
    - template: jinja

{% elif ('head' in grains.get('product_version') | default('', true)) or ('test' in grains.get('product_version') | default('', true)) %}
tools_additional_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-15-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-15-x86_64.repo
    - template: jinja

{% endif %}
{% endif %} {# not grains.get('role') or not grains.get('role').startswith('suse_manager') #}
{% endif %} {# '15' in grains['osrelease'] #}

{% if '15' == grains['osrelease'] %}
os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-15-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-15-x86_64-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-15-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-15-x86_64-Update.repo
    - template: jinja

{% if grains.get('use_os_unreleased_updates') | default(False, true) %}
test_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-15-x86_64-Test-Update.repo
    - source: salt://repos/repos.d/SLE-15-x86_64-Test-Update.repo
    - template: jinja
{% endif %}
{% endif %} {# '15' == grains['osrelease'] #}

{% if '15.1' == grains['osrelease'] %}
os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-15-SP1-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-15-SP1-x86_64-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-15-SP1-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-15-SP1-x86_64-Update.repo
    - template: jinja
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

{% if grains.get('product_version') == 'test' %}
allow_all_vendor_changes:
  file.append:
    - name: /etc/zypp/zypp.conf
    - text: solver.allowVendorChange = true
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

{% if grains.get('osmajorrelease', None)|int() == 7 %}
tools_pool_repo:
  file.managed:
    - name: /etc/yum.repos.d/SLE-Manager-Tools-RES-7-x86_64.repo
    - source: salt://repos/repos.d/SLE-Manager-Tools-RES-7-x86_64.repo
    - template: jinja
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

{% if 'head' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  file.managed:
    - name: /etc/yum.repos.d/Devel_Galaxy_Manager_Head_RES-Manager-Tools-7-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_Head_RES-Manager-Tools-7-x86_64.repo
    - template: jinja
    - require:
      - cmd: galaxy_key

{% elif 'nightly' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  file.managed:
    - name: /etc/yum.repos.d/Devel_Galaxy_Manager_4.0_RES-Manager-Tools-7-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_4.0_RES-Manager-Tools-7-x86_64.repo
    - template: jinja
    - require:
      - cmd: galaxy_key
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
{% set tools_repo_url = 'http://download.suse.de/ibs/Devel:/Galaxy:/Manager:/Head:/Ubuntu18.04-SUSE-Manager-Tools/xUbuntu_18.04' %}
{% elif '4.0' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://download.suse.de/ibs/Devel:/Galaxy:/Manager:/4.0:/Ubuntu18.04-SUSE-Manager-Tools/xUbuntu_18.04' %}
{% elif '3.2' in grains.get('product_version') | default('', true) %}
# We only have one shared Client Tools repository, so we are using 4.0 even for 3.2
{% set tools_repo_url = 'http://download.suse.de/ibs/Devel:/Galaxy:/Manager:/4.0:/Ubuntu18.04-SUSE-Manager-Tools/xUbuntu_18.04' %}
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Master:/Ubuntu1804-Uyuni-Client-Tools/xUbuntu_18.04' %}
{% elif 'uyuni-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Stable:/Ubuntu1804-Uyuni-Client-Tools/xUbuntu_18.04' %}
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
{% elif '4.0' in grains.get('product_version') | default('', true) %}
    - text: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:4.0:Ubuntu18.04-SUSE-Manager-Tools
            Pin-Priority: 800
{% elif '3.2' in grains.get('product_version') | default('', true) %}
# We only have one shared Client Tools repository, so we are using 4.0 even for 3.2
    - text: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:4.0:Ubuntu18.04-SUSE-Manager-Tools
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

{% if grains['additional_repos'] %}
{% for label, url in grains['additional_repos'].items() %}
{{ label }}_repo:
  pkgrepo.managed:
    - humanname: {{ label }}
  {%- if grains['os_family'] == 'Debian' %}
    - name: deb {{ url }} /
    - file: /etc/apt/sources.list.d/sumaform_additional_repos.list
    - key_url: {{ url }}/Release.key
  {%- else %}
    - baseurl: {{ url }}
    - priority: 94
    - gpgcheck: 0
  {%- endif %}

# HACK: to have additional_repos have priority over normal tools we hardcode the hostname originating them (in the future we may want to add an
# input variable to match against origin or release file fields
# Ref: https://wiki.debian.org/AptPreferences
{% if grains['os_family'] == 'Debian' and grains['os'] == 'Ubuntu' %}
{{ label }}_customrepo_raised_priority:
  file.append:
    - name: /etc/apt/preferences.d/sumaform_additional_repos
    - text: |
        Package: *
        Pin: origin download.opensuse.org
        Pin-Priority: 900
        Package: *
        Pin: origin download.suse.de
        Pin-Priority: 850
    - unless: ls /etc/apt/preferences.d/sumaform_additional_repos
{% endif %}
{% endfor %}
{% endif %}

{% if grains['os_family'] == 'Debian' %}
remove_no_install_recommends:
  file.absent:
    - name: /etc/apt/apt.conf.d/00InstallRecommends
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

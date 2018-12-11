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

{% if grains['osrelease'] == '42.3' %}
os_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-42.3-Pool.repo
    - source: salt://repos/repos.d/openSUSE-Leap-42.3-Pool.repo
    - template: jinja

os_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-42.3-Update.repo
    - source: salt://repos/repos.d/openSUSE-Leap-42.3-Update.repo
    - template: jinja
{% endif %} {# grains['osrelease'] == '42.3' #}


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

{% if grains.get('use_unreleased_updates') | default(False, true) %}
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
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.2_SLE-Manager-Tools-11-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_3.2_SLE-Manager-Tools-11-x86_64.repo
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

{% if grains.get('use_unreleased_updates') | default(False, true) %}
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

{% if grains.get('use_unreleased_updates') | default(False, true) %}
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

{% if grains.get('use_unreleased_updates') | default(False, true) %}
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

{% if grains.get('use_unreleased_updates') | default(False, true) %}
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

{% if grains.get('use_unreleased_updates') | default(False, true) %}
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
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.2_SLE-Manager-Tools-12-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_3.2_SLE-Manager-Tools-12-x86_64.repo
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

{% if grains.get('use_unreleased_updates') | default(False, true) %}
test_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-15-x86_64-Test-Update.repo
    - source: salt://repos/repos.d/SLE-15-x86_64-Test-Update.repo
    - template: jinja
{% endif %}

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
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.2_SLE-Manager-Tools-15-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_3.2_SLE-Manager-Tools-15-x86_64.repo
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
    - name: /etc/yum.repos.d/Devel_Galaxy_Manager_3.2_RES-Manager-Tools-7-x86_64.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_3.2_RES-Manager-Tools-7-x86_64.repo
    - template: jinja
    - require:
      - cmd: galaxy_key
{% endif %}
{% endif %} {# grains.get('osmajorrelease', None)|int() == 7 #}

{% endif %} {# grains['os_family'] == 'RedHat' #}

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
{% endfor %}
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

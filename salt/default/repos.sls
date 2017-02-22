{% if grains['os'] == 'SUSE' %}

{% if grains['osrelease'] == '42.2' %}
os-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-42.2-Pool.repo
    - source: salt://default/repos.d/openSUSE-Leap-42.2-Pool.repo
    - template: jinja

os-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/openSUSE-Leap-42.2-Update.repo
    - source: salt://default/repos.d/openSUSE-Leap-42.2-Update.repo
    - template: jinja

tools-pool-repo:
  file.touch:
    - name: /tmp/no_tools_pool_channel_needed

tools-update-repo:
  file.touch:
    - name: /tmp/no_tools_update_channel_needed
{% endif %}


{% if '11' in grains['osrelease'] %}
{% if grains['osrelease'] == '11.3' %}
os-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP3-x86_64-Pool.repo
    - source: salt://default/repos.d/SLE-11-SP3-x86_64-Pool.repo
    - template: jinja

os-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP3-x86_64-Update.repo
    - source: salt://default/repos.d/SLE-11-SP3-x86_64-Update.repo
    - template: jinja
{% elif grains['osrelease'] == '11.4' %}
os-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP4-x86_64-Pool.repo
    - source: salt://default/repos.d/SLE-11-SP4-x86_64-Pool.repo
    - template: jinja

os-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP4-x86_64-Update.repo
    - source: salt://default/repos.d/SLE-11-SP4-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if 'stable' in grains.get('version', 'stable') %}
tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-11-x86_64.repo
    - source: salt://default/repos.d/SLE-Manager-Tools-SLE-11-x86_64.repo
    - template: jinja
{% elif 'nightly' in grains.get('version', '') %}
tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.0_SLE-Manager-Tools-11-x86_64.repo
    - source: salt://default/repos.d/Devel_Galaxy_Manager_3.0_SLE-Manager-Tools-11-x86_64.repo
    - template: jinja
{% elif 'head' in grains.get('version', '') %}
tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-11-x86_64.repo
    - source: salt://default/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-11-x86_64.repo
    - template: jinja
{% endif %}

tools-update-repo:
  file.touch:
    - name: /tmp/no_tools_update_channel_needed
{% endif %}



{% if '12' in grains['osrelease'] %}
{% if grains['osrelease'] == '12' %}
os-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-x86_64-Pool.repo
    - source: salt://default/repos.d/SLE-12-x86_64-Pool.repo
    - template: jinja

os-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-x86_64-Update.repo
    - source: salt://default/repos.d/SLE-12-x86_64-Update.repo
    - template: jinja
{% elif grains['osrelease'] == '12.1' %}
os-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-x86_64-Pool.repo
    - source: salt://default/repos.d/SLE-12-SP1-x86_64-Pool.repo
    - template: jinja

os-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-x86_64-Update.repo
    - source: salt://default/repos.d/SLE-12-SP1-x86_64-Update.repo
    - template: jinja
{% elif grains['osrelease'] == '12.2' %}
os-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP2-x86_64-Pool.repo
    - source: salt://default/repos.d/SLE-12-SP2-x86_64-Pool.repo
    - template: jinja

os-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP2-x86_64-Update.repo
    - source: salt://default/repos.d/SLE-12-SP2-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if 'head' in grains.get('version', '') or '3.1-stable' in grains.get('version', '') %}
tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-12-x86_64.repo
    - source: salt://default/repos.d/Devel_Galaxy_Manager_Head_SLE-Manager-Tools-12-x86_64.repo
    - template: jinja

tools-update-repo:
  file.touch:
    - name: /tmp/no_tools_update_channel_needed
{% elif 'nightly' in grains.get('version', '') %}
tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.0_SLE-Manager-Tools-12-x86_64.repo
    - source: salt://default/repos.d/Devel_Galaxy_Manager_3.0_SLE-Manager-Tools-12-x86_64.repo
    - template: jinja

tools-update-repo:
  file.touch:
    - name: /tmp/no_tools_update_channel_needed
{% elif 'stable' in grains.get('version', 'stable') %}
tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
    - source: salt://default/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
    - template: jinja

tools-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
    - source: salt://default/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
    - template: jinja
{% endif %}
{% endif %}

{% for label, url in grains['additional_repos'].items() %}
{{ label }}-repo:
  pkgrepo.managed:
    - humanname: {{ label }}
    - baseurl: {{ url }}
    - priority: 98
{% endfor %}

allow-vendor-changes:
  file.managed:
    - name: /etc/zypp/vendors.d/suse
    - makedirs: True
    - contents: |
        [main]
        vendors = SUSE,obs://build.suse.de/Devel:Galaxy

refresh-default-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: os-pool-repo
      - file: os-update-repo
      - file: tools-pool-repo
      - file: tools-update-repo

{% else %}

{% if 'additional_repos' in grains %}
{% for label, url in grains['additional_repos'].items() %}
{{ label }}:
  pkgrepo.managed:
    - humanname: {{ label }}
    - baseurl: {{ url }}
    - priority: 98
{% endfor %}
{% endif %}

no-default-repos:
  test.nop: []
{% endif %}

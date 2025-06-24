{# These states set up client tools repositories for all supported OSes #}

{% if not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles') and 'server_containerized' not in grains.get('roles') and 'proxy_containerized' not in grains.get('roles')) %}
{# no client tools on server, proxy, server_containerized, or proxy_containerized #}
{% if '4.3' in grains.get('product_version') or '5.0' in grains.get('product_version') and %}

{% if grains['os'] == 'SUSE' %}
{% if grains['osfullname'] == 'Leap' %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15/{{ grains.get("cpuarch") }}/product/
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% elif grains['osfullname'] == 'SLES' %}

{% if '12' in grains['osrelease'] %}

## Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE12-Uyuni-Client-Tools/SLE_12/
    - refresh: True

## Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

{% if 'client' in grains.get('roles') %}
tools_trad_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-POOL-x86_64-Media1/
    - refresh: True
    - priority: 98
{% endif %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-POOL-x86_64-Media1/
    - refresh: True
    - priority: 98

{% endif %} {# '12' in grains['osrelease'] #}


{% if '15' in grains['osrelease'] %}

## Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True

## Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

{% if 'client' in grains.get('roles') %}
tools_trad_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
  - refresh: True
  - priority: 98
{% endif %}

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
  - refresh: True
  - priority: 98

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
  - refresh: True
  - priority: 98

{% endif %} {# '15' in grains['osrelease'] #}

{% elif grains['osfullname'] == 'SL-Micro' %}

# Released Tools repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SL-Micro-6-SUSE-Manager-Tools/SL-Micro6/
    - refresh: True
{#    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-SL-Micro-6/.... #}

{% elif grains['osfullname'] == 'SLE Micro' %}

# Released Tools repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True

# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-x86_64-Media1/
  - refresh: True
  - priority: 98

{% endif %} {# grains['osfullname'] == 'SLE Micro' #}

{% endif %} {# grains['os'] == 'SUSE' #}

{% if grains['os_family'] == 'RedHat' %}

{% set release = grains.get('osmajorrelease', None)|int() %}


{% if not grains.get('product_version') or not grains.get('product_version').startswith('uyuni-') %} {# Released Tools Repos #}

{% set rhlike_client_tools_prefix = 'EL' %}
{% if release < 9 %}
{% set rhlike_client_tools_prefix = 'RES' %}
{% endif %}

tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    {% if release >= 8 %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/{{ rhlike_client_tools_prefix }}/{{ release }}-CLIENT-TOOLS/x86_64/product/
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/RES{{ release }}-SUSE-Manager-Tools/x86_64/
    {% else %}
    # Amazon Linux support
    {% if release == 2 %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/RES/7-CLIENT-TOOLS/x86_64/product/
    {% else %}
    - baseurl: http://dist.nue.suse.com/ibs/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS/x86_64/update/
    {% endif %}
    {% endif %}
    - refresh: True

{% else %}

{% set rhlike_client_tools_prefix = 'EL' %}
{% if release < 8 %}
{% set rhlike_client_tools_prefix = 'CentOS' %}
{% endif %}

tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/{{ rhlike_client_tools_prefix }}{{ release }}-Uyuni-Client-Tools/{{ rhlike_client_tools_prefix }}_{{ release }}/
    - refresh: True
    - require:
      - cmd: uyuni_key


{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

{% set rhlike_client_tools_prefix = 'EL' %}
{% if release < 9 %}
{% set rhlike_client_tools_prefix = 'RES' %}
{% endif %}

{% if 'client' in grains.get('roles') %}
tools_update_trad_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/{{ rhlike_client_tools_prefix }}{{ release }}-SUSE-Manager-Tools/SUSE_{{ rhlike_client_tools_prefix }}-{{ release }}_Update_standard/
    - refresh: True
    - require:
      - cmd: galaxy_key
    {% if release >= 9 %}
      - cmd: suse_el9_key
    {% else %}
      - cmd: suse_res7_key
    {% endif %}
{% endif %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0:/{{ rhlike_client_tools_prefix }}{{ release }}-SUSE-Manager-Tools/SUSE_{{ rhlike_client_tools_prefix }}-{{ release }}_Update_standard/
    - refresh: True
    - require:
      - cmd: galaxy_key
    {% if release >= 9 %}
      - cmd: suse_el9_key
    {% else %}
      - cmd: suse_res7_key
    {% endif %}

{% endif %} {# release >= 8 #}
{% endif %} {# Devel Tools Repos #}

clean_repo_metadata:
  cmd.run:
    - name: yum clean metadata

{% endif %} {# grains['os_family'] == 'RedHat' #}


{% if grains['os'] == 'Ubuntu' %}

{% set release = grains.get('osrelease', None) %}
{% set short_release = release | replace('.', '') %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - file: /etc/apt/sources.list.d/tools_update_repo.list
# We only have one shared Client Tools repository
{% if 'head' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-Ubuntu' + release + '/xUbuntu_' + release %}
{% elif 'beta' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS-BETA/x86_64/update/' %}
{% elif 'nightly' in grains.get('product_version') | default('', true) %}
{# 5.0 is intentional here (shared tools) #}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.0:/Ubuntu' + release + '-SUSE-Manager-Tools/xUbuntu_' + release %}
{% elif '4.3-released' in grains.get('product_version') | default('', true) %}
{# TODO: remove extra code when Ubuntu 24.04 tools get released #}
{# 5.0 is intentional here (shared tools) #}
{% if release == '24.04' %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.0:/Ubuntu24.04-SUSE-Manager-Tools/xUbuntu_24.04' %}
{% else %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
{% endif %}
{% elif '4.3-VM-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
{% elif '5.0-nightly' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.0:/Ubuntu' + release + '-SUSE-Manager-Tools/xUbuntu_' + release %}
{% elif '5.0-released' in grains.get('product_version') | default('', true) %}
{# TODO: remove extra code when Ubuntu 24.04 tools get released #}
{% if release == '24.04' %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.0:/Ubuntu24.04-SUSE-Manager-Tools/xUbuntu_24.04' %}
{% else %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
{% endif %}
{% elif '5.1-nightly' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.1:/Ubuntu' + release + '-SUSE-Manager-Tools/xUbuntu_' + release %}
{% elif '5.1-released' in grains.get('product_version') | default('', true) %}
{# TODO: remove extra code when Ubuntu 24.04 tools get released #}
{% if release == '24.04' %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-Ubuntu24.04/xUbuntu_24.04' %}
{% else %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-MultiLinuxManagerTools/x86_64/update/' %}
{% endif %}
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
{% elif '4.3-nightly' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:4.3:Ubuntu{{ release }}-SUSE-Manager-Tools
            Pin-Priority: 800
{% elif '4.3-released' in grains.get('product_version') | default('', true) %}
{# TODO: remove extra code when Ubuntu 24.04 tools get released #}
{# 5.0 is intentional here (shared tools) #}
    - contents: |
            Package: *
{%- if release == '24.04' %}
            Pin: release l=Devel:Galaxy:Manager:5.0:Ubuntu24.04-SUSE-Manager-Tools
{%- else %}
            Pin: release l=SUSE:Updates:Ubuntu:{{ release }}-CLIENT-TOOLS:x86_64:update
{%- endif %}
            Pin-Priority: 800
{% elif '4.3-VM-released' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=SUSE:Updates:Ubuntu:{{ release }}-CLIENT-TOOLS:x86_64:update
            Pin-Priority: 800
{% elif '5.0-nightly' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:5.0:Ubuntu{{ release }}-SUSE-Manager-Tools
            Pin-Priority: 800
{% elif '5.0-released' in grains.get('product_version') | default('', true) %}
{# TODO: remove extra code when Ubuntu 24.04 tools get released #}
    - contents: |
            Package: *
{%- if release == '24.04' %}
            Pin: release l=Devel:Galaxy:Manager:5.0:Ubuntu24.04-SUSE-Manager-Tools
{%- else %}
            Pin: release l=SUSE:Updates:Ubuntu:{{ release }}-CLIENT-TOOLS:x86_64:update
{%- endif %}
            Pin-Priority: 800
{% elif '5.1-nightly' in grains.get('product_version') | default('', true) %}
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:5.1:MLMTools-Ubuntu{{ release }}
            Pin-Priority: 800
{% elif '5.1-released' in grains.get('product_version') | default('', true) %}
{# TODO: remove extra code when Ubuntu 24.04 tools get released #}
    - contents: |
            Package: *
{%- if release == '24.04' %}
            Pin: release l=Devel:Galaxy:Manager:5.1:MLMTools-Ubuntu24.04
{%- else %}
            Pin: release l=SUSE:Updates:MultiLinuxManagerTools:Ubuntu-{{ release }}:x86_64
{%- endif %}
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
{% endif %} {# grains['os'] == 'Ubuntu' #}

{% if grains['os'] == 'Debian' %}

{% set release = grains.get('osrelease', None) %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - file: /etc/apt/sources.list.d/tools_update_repo.list
    # We only have one shared Client Tools repository
{% if '4.3-nightly' in grains.get('product_version') | default('', true) %}
{# 5.0 is intentional here (shared tools) #}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.0:/Debian' + release + '-SUSE-Manager-Tools/Debian_' + release %}
{% elif '5.0-nightly' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.0:/Debian' + release + '-SUSE-Manager-Tools/Debian_' + release %}
{% elif '5.1-nightly' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-Debian' + release + '/Debian_' + release %}
{% elif 'head' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-Debian' + release + '/Debian_' + release %}
{% elif 'beta' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS-BETA/x86_64/update/' %}
{% elif '4.3-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
{% elif '4.3-VM-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
{% elif '5.0-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
{% elif '5.1-released' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Debian/' + release + '-MultiLinuxManagerTools/x86_64/update/' %}
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Master:/Debian' + release + '-Uyuni-Client-Tools/Debian_' + release %}
{% else %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Stable:/Debian' + release + '-Uyuni-Client-Tools/Debian_' + release %}
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
        Pin: release l=Devel:Galaxy:Manager:Head:Debian{{ release }}-SUSE-Manager-Tools
        Pin-Priority: 800
{% elif '4.3-nightly' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=Devel:Galaxy:Manager:5.0:Debian{{ release }}-SUSE-Manager-Tools
        Pin-Priority: 800
{% elif '4.3-released' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=SUSE:Updates:Debian:{{ release }}-CLIENT-TOOLS:x86_64:update
        Pin-Priority: 800
{% elif '4.3-VM-released' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=SUSE:Updates:Debian:{{ release }}-CLIENT-TOOLS:x86_64:update
        Pin-Priority: 800
{% elif '5.0-nightly' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=Devel:Galaxy:Manager:5.0:Debian{{ release }}-SUSE-Manager-Tools
        Pin-Priority: 800
{% elif '5.0-released' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=SUSE:Updates:Debian:{{ release }}-CLIENT-TOOLS:x86_64:update
        Pin-Priority: 800
{% elif '5.1-nightly' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=Devel:Galaxy:Manager:5.1:MLMTools-Debian{{ release }}
        Pin-Priority: 800
{% elif '5.1-released' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=SUSE:Updates:MultiLinuxManagerTools:Debian-{{release}}:x86_64:update
        Pin-Priority: 800
{% elif 'uyuni-master' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=systemsmanagement:Uyuni:Master:Debian{{ release }}-Uyuni-Client-Tools
        Pin-Priority: 800
{% elif 'uyuni-released' in grains.get('product_version') | default('', true) %}
    - contents: |
        Package: *
        Pin: release l=systemsmanagement:Uyuni:Stable:Debian{{ release }}-Uyuni-Client-Tools
        Pin-Priority: 800
{% endif %}
{% endif %} {# grains['os'] == 'Debian' #}
{% endif %} {# no client tools on server or proxy #}

{# WORKAROUND: see github:saltstack/salt#10852 #}
{{ sls }}_nop:
  test.nop: []

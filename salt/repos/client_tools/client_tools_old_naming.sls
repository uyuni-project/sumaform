{# These states set up client tools repositories for all supported OSes #}
{% set product_version = grains.get('product_version') | default('', true) %}
{% if '4.3' in product_version or '5.0' in product_version %}
{% if not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles') and 'server_containerized' not in grains.get('roles') and 'proxy_containerized' not in grains.get('roles')) %}
{# no client tools on server, proxy, server_containerized, or proxy_containerized #}

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

{% endif %} {# Devel Tools Repos #}
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

{% endif %} {# Devel Tools Repos #}
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

{% endif %} {# Devel Tools Repos #}
{% endif %} {# grains['osfullname'] == 'SLE Micro' #}

{% endif %} {# grains['os'] == 'SUSE' #}

{% if grains['os_family'] == 'RedHat' %}

# Set release to 9 for AmazonLinux2023 and OpenEuler. osmajorrelease is 2023 or 24
{% set os_major = grains.get('osmajorrelease', 0) | int %}
{% set release = 9 if os_major >= 9 else os_major %}

# RES extension is only used for centos7
{% set rhlike_client_tools_prefix = 'RES' if release < 9 else 'EL' %}

# Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    {% if release >= 8 %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/{{ rhlike_client_tools_prefix }}/{{ release }}-CLIENT-TOOLS/x86_64/product/
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/RES{{ release }}-SUSE-Manager-Tools/x86_64/
    {% endif %}
    {% else %}
    # Amazon Linux support
    {% if release == 2 %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/RES/7-CLIENT-TOOLS/x86_64/product/
    {% else %}
    - baseurl: http://dist.nue.suse.com/ibs/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS/x86_64/update/
    {% endif %}
    {% endif %}
    - refresh: True

# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

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

{% endif %} {# Devel Tools Repos #}

clean_repo_metadata:
  cmd.run:
    - name: yum clean metadata

{% endif %} {# grains['os_family'] == 'RedHat' #}


{% if grains['os'] == 'Ubuntu' %}

{% set release = grains.get('osrelease', None) %}
{% set short_release = release | replace('.', '') %}

# Release client tools
{% set tools_update_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - file: /etc/apt/sources.list.d/tools_update_repo.list
    - refresh: True
    - name: deb {{ tools_update_repo }} /
    - key_url: {{ tools_update_repo }}/Release.key

tools_update_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/tools_update_repo
    - contents: |
            Package: *
            Pin: release l=SUSE:Updates:Ubuntu:{{ release }}-CLIENT-TOOLS:x86_64:update
            Pin-Priority: 800

{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

{% set tools_additional_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.0:/Ubuntu' + release + '-SUSE-Manager-Tools/xUbuntu_' + release %}
tools_additional_repo:
  pkgrepo.managed:
    - humanname: tools_additional_repo
    - file: /etc/apt/sources.list.d/tools_additional_repo.list
    - refresh: True
    - name: deb {{ tools_additional_repo }} /
    - key_url: {{ tools_additional_repo }}/Release.key

tools_additional_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/tools_additional_repo
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:5.0:Ubuntu{{ release }}-SUSE-Manager-Tools
            Pin-Priority: 800

{% endif %} {# Devel Tools Repos #}
{% endif %} {# grains['os'] == 'Ubuntu' #}

{% if grains['os'] == 'Debian' %}

{% set release = grains.get('osrelease', None) %}

{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - file: /etc/apt/sources.list.d/tools_update_repo.list
    - refresh: True
    - name: deb {{ tools_repo_url }} /
    - key_url: {{ tools_repo_url }}/Release.key
    # We only have one shared Client Tools repository

tools_update_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/tools_update_repo
    - contents: |
        Package: *
        Pin: release l=SUSE:Updates:Debian:{{ release }}-CLIENT-TOOLS:x86_64:update
        Pin-Priority: 800

{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

{% set tools_additional_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.0:/Debian' + release + '-SUSE-Manager-Tools/Debian_' + release %}
tools_additional_repo:
  pkgrepo.managed:
    - humanname: tools_additional_repo
    - file: /etc/apt/sources.list.d/tools_additional_repo.list
    - refresh: True
    - name: deb {{ tools_additional_repo }} /
    - key_url: {{ tools_additional_repo }}/Release.key

tools_additional_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/tools_additional_repo
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:5.0:Debian{{ release }}-SUSE-Manager-Tools
            Pin-Priority: 800

{% endif %} {# Devel Tools Repos #}
{% endif %} {# grains['os'] == 'Debian' #}

{% endif %} {# no client tools on server or proxy #}

{# WORKAROUND: see github:saltstack/salt#10852 #}
{{ sls }}_nop:
  test.nop: []
{% endif %} {# 4.3 or 5.0 product version #}

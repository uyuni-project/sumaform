{# These states set up client tools repositories for all supported OSes #}
{% set product_version = grains.get('product_version') | default('', true) %}
{% if '4.3' in product_version or '5.0' in product_version %}
{% if not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles') and 'server_containerized' not in grains.get('roles') and 'proxy_containerized' not in grains.get('roles') and 'controller' not in grains.get('roles')) %}
{# no client tools on server, proxy, server_containerized, or proxy_containerized #}

## Important note: 4.3 and 5.0 are sharing the same client tools

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
{% endif %} {# grains['osfullname'] == 'Leap' #}
{% if grains['osfullname'] == 'SLES' %}

{% if '12' in grains['osrelease'] %}

## Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/12/{{ grains.get("cpuarch") }}/product/
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/12/{{ grains.get("cpuarch") }}/update/
    - refresh: True

## Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

{% if 'client' in grains.get('roles') %}
tools_trad_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-POOL-{{ grains.get("cpuarch") }}-Media1/
    - refresh: True
    - priority: 98
{% endif %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-POOL-{{ grains.get("cpuarch") }}-Media1/
    - refresh: True
    - priority: 98

{% endif %} {# Devel Tools Repos #}
{% endif %} {# '12' in grains['osrelease'] #}

{% if '15' in grains['osrelease'] %}

## Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Manager-Tools/15/{{ grains.get("cpuarch") }}/product/
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools/15/{{ grains.get("cpuarch") }}/update/
    - refresh: True

## Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

{% if 'client' in grains.get('roles') %}
tools_trad_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-{{ grains.get("cpuarch") }}-Media1/
  - refresh: True
  - priority: 98
{% endif %}

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-{{ grains.get("cpuarch") }}-Media1/
  - refresh: True
  - priority: 98

{% endif %} {# Devel Tools Repos #}
{% endif %} {# '15' in grains['osrelease'] #}

{% if '16' in grains['osrelease'] %}

## Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools/SLE-16/{{ grains.get("cpuarch") }}/
    - refresh: True

## Devel Tools Repos
tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-SLE-16.0/product/repo/Multi-Linux-ManagerTools-SLE-16-{{ grains.get("cpuarch") }}/
    - refresh: True
    - priority: 98
    - gpgcheck: 0

{% endif %} {# '16' in grains['osrelease'] #}

{% endif %} {# grains['osfullname'] == 'SLES' #}
{% if grains['osfullname'] == 'SL-Micro' %}

# Released Tools repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SUSE-Manager-Tools-For-SL-Micro/6/{{ grains.get("cpuarch") }}/product/
    - refresh: True

{% endif %} {# grains['osfullname'] == 'SL-Micro' #}
{% if grains['osfullname'] == 'SLE Micro' %}

# Released Tools repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Manager-Tools-For-Micro/5/{{ grains.get("cpuarch") }}/product/
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Manager-Tools-For-Micro/5/{{ grains.get("cpuarch") }}/update/
    - refresh: True

# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.0:/SLE15-SUSE-Manager-Tools/images/repo/SLE-15-Manager-Tools-POOL-{{ grains.get("cpuarch") }}-Media1/
  - refresh: True
  - priority: 98

{% endif %} {# Devel Tools Repos #}
{% endif %} {# grains['osfullname'] == 'SLE Micro' #}

{% endif %} {# grains['os'] == 'SUSE' #}

{% if grains['os_family'] == 'RedHat' %}

# Set release to 9 for AmazonLinux2023 and OpenEuler and release to 7 for AmazonLinux2
{% set release = grains.get('osmajorrelease', 0) | int %}
{% if grains['os'] == 'Amazon' and release == 2 %}
{% set release = 7 %}
{% elif grains['os'] == 'Amazon' and release == 2023 %}
{% set release = 9 %}
{% elif grains['os'] == 'openEuler' and release == 24 %}
{% set release = 9 %}
{% endif %}

# RES extension is only used for centos7
{% set rhlike_client_tools_prefix = 'RES' if release < 9 else 'EL' %}

# Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    {% if release >= 8 %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/{{ rhlike_client_tools_prefix }}/{{ release }}-CLIENT-TOOLS/{{ grains.get("cpuarch") }}/product/
    {% else %}
    # Centos7 release channel
    {% if grains.get('mirror') %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/RES{{ release }}-SUSE-Manager-Tools/{{ grains.get("cpuarch") }}/
    {% else %}
    - baseurl: http://dist.nue.suse.com/ibs/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS/{{ grains.get("cpuarch") }}/update/
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
{% set tools_update_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/' + grains.get("cpuarch") + '/update/' %}
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
            Pin: release l=SUSE:Updates:Ubuntu:{{ release }}-CLIENT-TOOLS:{{ grains.get("cpuarch") }}:update
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

{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS/' + grains.get("cpuarch") + '/update/' %}
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
        Pin: release l=SUSE:Updates:Debian:{{ release }}-CLIENT-TOOLS:{{ grains.get("cpuarch") }}:update
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
{% endif %} {# 4.3 or 5.0 product version #}

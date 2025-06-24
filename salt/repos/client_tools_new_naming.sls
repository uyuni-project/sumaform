{# These states set up client tools repositories for all supported OSes #}

{% if not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles') and 'server_containerized' not in grains.get('roles') and 'proxy_containerized' not in grains.get('roles')) %}
{# no client tools on server, proxy, server_containerized, or proxy_containerized #}
{% if '5.1' in grains.get('product_version') or 'head' in grains.get('product_version') %}


{% if grains['os'] == 'SUSE' %}
{% if grains['osfullname'] == 'Leap' %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools/SLE-15/{{ grains.get("cpuarch") }}/product/
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools/SLE-15/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% if 'beta' in grains.get('product_version') | default('', true) %}
beta_tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools-Beta/SLE-15/{{ grains.get("cpuarch") }}/product/
    - refresh: True

beta_tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools-Beta/SLE-15/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% endif %} {# 'beta' in grains.get('product_version') #}


{% elif grains['osfullname'] == 'SLES' %}

{% if '12' in grains['osrelease'] %}

# Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools/SLE-12/{{ grains.get("cpuarch") }}/product/
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools/SLE-12/{{ grains.get("cpuarch") }}/update/
    - refresh: True

# Beta Tools Repos
{% if 'beta' in grains.get('product_version') | default('', true) %}
beta_tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools-Beta/SLE-12/{{ grains.get("cpuarch") }}/product/
    - refresh: True

beta_tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools-Beta/SLE-12/{{ grains.get("cpuarch") }}/update/
    - refresh: True
{% endif %} {# 'beta' in grains.get('product_version') #}


# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-SLE12/images/repo/ManagerTools-SLE12-Pool-{{ grains.get("cpuarch") }}-Media1/
    - refresh: True
    - priority: 98

{% elif 'head' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-SLE12/images/repo/ManagerTools-Beta-SLE12-Pool-x86_64-Media1/
    - refresh: True
    - priority: 98

{% endif %} {# Devel Tools Repos #}

{% endif %} {# '12' in grains['osrelease'] #}


{% if '15' in grains['osrelease'] %}

# Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools/SLE-15/{{ grains.get("cpuarch") }}/product/
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools/SLE-15/{{ grains.get("cpuarch") }}/update/
    - refresh: True

# Beta Tools Repos
{% if 'beta' in grains.get('product_version') | default('', true) %}
beta_tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools-Beta/SLE-15/{{ grains.get("cpuarch") }}/product/
    - refresh: True

beta_tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools-Beta/SLE-15/{{ grains.get("cpuarch") }}/update/
    - refresh: True
{% endif %}


{% endif %} {# Released Tools repos #}

# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-SLE15/images/repo/ManagerTools-SLE15-Pool-{{ grains.get("cpuarch") }}-Media1/
  - refresh: True
  - priority: 98

{% elif 'head' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-SLE15/images/repo/ManagerTools-Beta-SLE15-Pool-x86_64-Media1/
    - refresh: True
    - priority: 98

{% endif %} {# Devel Tools Repos #}
{% endif %} {# '15' in grains['osrelease'] #}

{% elif grains['osfullname'] == 'SL-Micro' %}


# Release Tools Repos
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools/SL-Micro-6/{{ grains.get("cpuarch") }}/product/
    - refresh: True

# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-SL-Micro-6/product/repo/Multi-Linux-ManagerTools-SL-Micro-6-{{ grains.get("cpuarch") }}/
  - refresh: True
  - priority: 98

{% elif 'head' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-SLE15/images/repo/ManagerTools-Beta-SLE15-Pool-x86_64-Media1/
    - refresh: True
    - priority: 98

{% endif %} {# Devel Tools Repos #}

{% elif grains['osfullname'] == 'SLE Micro' %}

# Release Tools repo
tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools/SLE-Micro-5/{{ grains.get("cpuarch") }}/product/
    - refresh: True

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools/SLE-Micro-5/{{ grains.get("cpuarch") }}/update/
    - refresh: True

{% if 'beta' in grains.get('product_version') | default('', true) %}
beta_tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools-Beta/SLE-Micro-5//{{ grains.get("cpuarch") }}/product/
    - refresh: True

beta_tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools-Beta/SLE-Micro-5//{{ grains.get("cpuarch") }}/update/
    - refresh: True
{% endif %} {# 'beta' in grains.get('product_version') #}

{% endif %} {# Released Tools repos #}

{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

tools_additional_repo:
  pkgrepo.managed:
  - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-SLE15/images/repo/ManagerTools-SLE15-Pool-x86_64-Media1/
  - refresh: True
  - priority: 98

{% elif 'head' in grains.get('product_version') | default('', true) %}

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-SLE15/images/repo/ManagerTools-Beta-SLE15-Pool-x86_64-Media1/
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
{% set rhlike_client_tools_prefix = 'RES' if release < 8 else 'EL' %}

tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools/{{ rhlike_client_tools_prefix }}-{{ release }}/x86_64/product/

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools/{{ rhlike_client_tools_prefix }}-{{ release }}/x86_64/updates/

{% if 'beta' in grains.get('product_version') | default('', true) %}

beta_tools_pool_repo:
  pkgrepo.managed:
    - humanname: beta_tools_pool_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools-Beta/{{ rhlike_client_tools_prefix }}-{{ release }}/x86_64/product/

beta_tools_update_repo:
  pkgrepo.managed:
    - humanname: beta_tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools-Beta/{{ rhlike_client_tools_prefix }}-{{ release }}/x86_64/updates/

{% endif %}

# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    {%- if release >= 8 %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-EL{{release}}/images/repo/MultiLinuxManagerTools-EL-{{release}}-x86_64-Media1/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-EL{{release}}/images/repo/ManagerTools-EL{{release}}-POOL-x86_64-Media/
    {%- endif %}
    - refresh: True
    - require:
      - cmd: galaxy_key
    {% if release >= 9 %}
      - cmd: suse_el9_key
    {% else %}
      - cmd: suse_res7_key
    {% endif %}

{% elif 'head' in grains.get('product_version') | default('', true) %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    {%- if release >= 8 %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-EL{{ release }}/images/repo/MultiLinuxManagerTools-EL-{{ release }}-Beta-x86_64-Media1/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-EL{{ release }}/images/repo/ManagerTools-Beta-EL{{ release }}-POOL-x86_64-Media/
    {%- endif %}
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

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - file: /etc/apt/sources.list.d/tools_update_repo.list
# We only have one shared Client Tools repository
{% if 'head' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-Ubuntu' + release + '/xUbuntu_' + release %}
{% elif 'beta' in grains.get('product_version') | default('', true) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS-BETA/x86_64/update/' %}
{% elif '4.3-nightly' in grains.get('product_version') | default('', true) %}
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

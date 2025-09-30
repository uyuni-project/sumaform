{# These states set up client tools repositories for all supported OSes #}
{% set product_version = grains.get('product_version') | default('', true) %}
{% if '5.1' in product_version or 'head' in product_version %}
{% if not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles') and 'server_containerized' not in grains.get('roles') and 'proxy_containerized' not in grains.get('roles') and 'controller' not in grains.get('roles')) %}
{# no client tools on server, proxy, server_containerized, or proxy_containerized #}

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
{% endif %} {# grains['osfullname'] == 'Leap' #}
{% if grains['osfullname'] == 'SLES' %}

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
{% endif %} {# 'beta' in grains.get('product_version') #}

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
{% endif %} {# grains['osfullname'] == 'SLES' #}
{% if grains['osfullname'] == 'SL-Micro' %}

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
{% endif %} {# grains['osfullname'] == 'SL-Micro' #}
{% if grains['osfullname'] == 'SLE Micro' %}

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
{% set rhlike_client_tools_prefix = 'RES' if release < 8 else 'EL' %}

tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools/{{ rhlike_client_tools_prefix }}-{{ release }}/x86_64/product/

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools/{{ rhlike_client_tools_prefix }}-{{ release }}/x86_64/update/

{% if 'beta' in grains.get('product_version') | default('', true) %}

beta_tools_pool_repo:
  pkgrepo.managed:
    - humanname: beta_tools_pool_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/MultiLinuxManagerTools-Beta/{{ rhlike_client_tools_prefix }}-{{ release }}/x86_64/product/

beta_tools_update_repo:
  pkgrepo.managed:
    - humanname: beta_tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/MultiLinuxManagerTools-Beta/{{ rhlike_client_tools_prefix }}-{{ release }}/x86_64/update/

{% endif %}

# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}

tools_additional_repo:
  pkgrepo.managed:
    - humanname: tools_additional_repo
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

tools_additional_repo:
  pkgrepo.managed:
    - humanname: tools_additional_repo
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

# Release client tools
{% set tools_update_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/MultiLinuxManagerTools/Ubuntu-' + release + '/x86_64/update/' %}
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
            Pin: release l=SUSE:Updates:MultiLinuxManagerTools:Ubuntu-{{ release }}:x86_64:update
            Pin-Priority: 800

{% if 'beta' in grains.get('product_version') | default('', true) %}

{% set beta_tools_update_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/MultiLinuxManagerTools-Beta/Ubuntu-' + release + '/x86_64/update/' %}
beta_tools_update_repo:
  pkgrepo.managed:
    - humanname: beta_tools_update_repo
    - file: /etc/apt/sources.list.d/beta_tools_update_repo.list
    - refresh: True
    - name: deb {{ beta_tools_update_repo }} /
    - key_url: {{ beta_tools_update_repo }}/Release.key

beta_tools_update_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/beta_tools_update_repo
    - contents: |
            Package: *
            Pin: release l=SUSE:Updates:MultiLinuxManagerTools-Beta:Ubuntu-{{ release }}:x86_64:update
            Pin-Priority: 800

{% endif %}

# Devel Tools Repos
{% if 'nightly' in grains.get('product_version') | default('', true) %} {# Devel Tools Repos #}
{% set additional_tools_update_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-Ubuntu' + release + '/xUbuntu_' + release %}
additional_tools_update_repo:
  pkgrepo.managed:
    - humanname: additional_tools_update_repo
    - file: /etc/apt/sources.list.d/additional_tools_update_repo.list
    - refresh: True
    - name: deb {{ additional_tools_update_repo }} /
    - key_url: {{ additional_tools_update_repo }}/Release.key

additional_tools_update_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/additional_tools_update_repo
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:5.1:MLMTools-Ubuntu{{ release }}
            Pin-Priority: 800

{% elif 'head' in grains.get('product_version') | default('', true) %}

{% set additional_tools_update_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-Ubuntu' + release + '/xUbuntu_' + release %}
additional_tools_update_repo:
  pkgrepo.managed:
    - humanname: additional_tools_update_repo
    - file: /etc/apt/sources.list.d/additional_tools_update_repo.list
    - refresh: True
    - name: deb {{ additional_tools_update_repo }} /
    - key_url: {{ additional_tools_update_repo }}/Release.key

tools_additional_tools_update_repo:
  file.managed:
    - name: /etc/apt/preferences.d/additional_tools_update_repo
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:Head:MLMTools-Beta-Ubuntu{{ release }}
            Pin-Priority: 800

{% endif %} {# Devel Tools Repos #}
{% endif %} {# grains['os'] == 'Ubuntu' #}

{% if grains['os'] == 'Debian' %}

{% set release = grains.get('osrelease', None) %}

{% set tools_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/MultiLinuxManagerTools/Debian-' + release + '/x86_64/update/' %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - file: /etc/apt/sources.list.d/tools_update_repo.list
    - refresh: True
    - name: deb {{ tools_repo_url }} /
    - key_url: {{ tools_repo_url }}/Release.key

tools_update_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/tools_update_repo
    - contents: |
        Package: *
        Pin: release l=SUSE:Updates:MultiLinuxManagerTools:Debian-{{ release }}:x86_64:update
        Pin-Priority: 800

{% if 'beta' in grains.get('product_version') | default('', true) %}

{% set beta_tools_update_repo_url = 'http://' + grains.get("mirror") | default("dist.nue.suse.com/ibs", true) + '/SUSE/Updates/MultiLinuxManagerTools-Beta/Debian-' + release + '/x86_64/update/' %}
beta_tools_update_repo_url:
  pkgrepo.managed:
    - humanname: beta_tools_update_repo_url
    - file: /etc/apt/sources.list.d/beta_tools_update_repo_url.list
    - refresh: True
    - name: deb {{ beta_tools_update_repo_url }} /
    - key_url: {{ beta_tools_update_repo_url }}/Release.key

tools_update_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/tools_update_repo
    - contents: |
        Package: *
        Pin: release l=SUSE:Updates:MultiLinuxManagerTools-Beta:Debian-{{ release }}:x86_64:update
        Pin-Priority: 800

{% endif %} {# Beta Tools Repos #}

{% if 'nightly' in grains.get('product_version') | default('', true) %}

{% set tools_additional_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/5.1:/MLMTools-Debian' + release + '/Debian_' + release %}
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
            Pin: release l=Devel:Galaxy:Manager:5.1:MLMTools-Debian{{ release }}
            Pin-Priority: 800

{% elif 'head' in grains.get('product_version') | default('', true) %}

{% set tools_additional_repo = 'http://' + grains.get("mirror") | default("dist.nue.suse.com", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/MLMTools-Beta-Debian' + release + '/Debian_' + release %}
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
            Pin: release l=Devel:Galaxy:Manager:5.1:MLMTools-Beta-Debian{{ release }}
            Pin-Priority: 800

{% endif %} {# Devel Tools Repos #}
{% endif %} {# grains['os'] == 'Debian' #}
{% endif %} {# no client tools on server or proxy #}
{% endif %} {# 5.1 or head product version #}

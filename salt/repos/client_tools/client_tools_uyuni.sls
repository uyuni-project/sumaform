{# These states set up client tools repositories for all supported OSes #}
{% if 'uyuni' in grains.get('product_version') | default('', true) %}
{% if not grains.get('roles') or ('server' not in grains.get('roles') and 'proxy' not in grains.get('roles') and 'server_containerized' not in grains.get('roles') and 'proxy_containerized' not in grains.get('roles')) %}
{# no client tools on server, proxy, server_containerized, or proxy_containerized #}

{% set uyuni_version = 'Master' if grains.get('product_version', '') == 'uyuni-master' else 'Stable' %}

{% if grains['os'] == 'SUSE' %}
{% if grains['osfullname'] == 'Leap' %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/{{ uyuni_version }}:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_Leap_15.0/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/{{ uyuni_version }}:/openSUSE_Leap_15-Uyuni-Client-Tools/openSUSE_/Leap_15.0/repodata/repomd.xml.key

{% endif %} {# grains['osfullname'] == 'Leap' #}
{% if grains['osfullname'] == 'SLES' %}

{% if '12' in grains['osrelease'] %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE12-Uyuni-Client-Tools/SLE_12/
    - refresh: True

{% if 'uyuni-master' in grains.get('product_version') | default('', true) %}
tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE12-Uyuni-Client-Tools/SLE_12/
    - refresh: True
    - priority: 98
{% endif %}
{% endif %} {# '12' in grains['osrelease'] #}

{% if '15' in grains['osrelease'] %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True

{% if 'uyuni-master' in grains.get('product_version') | default('', true) %}

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/repodata/repomd.xml.key

{% endif %}

{% endif %} {# '15' in grains['osrelease'] #}
{% endif %} {# grains['osfullname'] == 'SLES' #}
{% if grains['osfullname'] == 'SL-Micro' %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True

tools_additional_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/SL-Micro-6-SUSE-Manager-Tools/SL-Micro6/
    - refresh: True

{% endif %} {# grains['osfullname'] == 'SL-Micro' #}
{% if grains['osfullname'] == 'SLE Micro' %}

tools_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True

{% if 'uyuni-master' in grains.get('product_version') | default('', true) %}

tools_update_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/SLE15-Uyuni-Client-Tools/SLE_15/repodata/repomd.xml.key
{% endif %}
{% endif %} {# grains['osfullname'] == 'SLE Micro' #}
{% endif %} {# grains['os'] == 'SUSE' #}

{% if grains['os_family'] == 'RedHat' %}

# Set release to 9 for AmazonLinux2023 and OpenEuler and release to 7 for AmazonLinux2
{% set release = grains.get('osmajorrelease', None)|int() %}
{% if grains['os'] == 'Amazon' and release == 2 %}
{% set release = 7 %}
{% elif grains['os'] == 'Amazon' and release == 2023 %}
{% set release = 9 %}
{% elif grains['os'] == 'openEuler' and release == 24 %}
{% set release = 9 %}
{% endif %}

{% set rhlike_client_tools_prefix = 'EL' %}
{% if release < 8 %}
{% set rhlike_client_tools_prefix = 'CentOS' %}
{% endif %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/{{ uyuni_version }}:/{{ rhlike_client_tools_prefix }}{{ release }}-Uyuni-Client-Tools/{{ rhlike_client_tools_prefix }}_{{ release }}/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/{{ uyuni_version }}:/{{ rhlike_client_tools_prefix }}{{ release }}-Uyuni-Client-Tools/{{ rhlike_client_tools_prefix }}_{{ release }}/repodata/repomd.xml.key
    - require:
      - cmd: uyuni_key

clean_repo_metadata:
  cmd.run:
    - name: yum clean metadata

{% endif %} {# grains['os_family'] == 'RedHat' #}

{% if grains['os'] == 'Ubuntu' %}

{% set release = grains.get('osrelease', None) %}
{% set short_release = release | replace('.', '') %}

{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/' + uyuni_version + ':/Ubuntu' + short_release + '-Uyuni-Client-Tools/xUbuntu_' + release %}
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
            Pin: release l=systemsmanagement:Uyuni:{{ uyuni_version }}:Ubuntu{{ short_release }}-Uyuni-Client-Tools
            Pin-Priority: 800

{% endif %} {# grains['os'] == 'Ubuntu' #}

{% if grains['os'] == 'Debian' %}

{% set release = grains.get('osrelease', None) %}
{% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/' + uyuni_version + ':/Debian' + release + '-Uyuni-Client-Tools/Debian_' + release %}
tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - file: /etc/apt/sources.list.d/tools_update_repo.list
    # We only have one shared Client Tools repository
    - refresh: True
    - name: deb {{ tools_repo_url }} /
    - key_url: {{ tools_repo_url }}/Release.key

tools_update_repo_raised_priority:
  file.managed:
    - name: /etc/apt/preferences.d/tools_update_repo
    - contents: |
        Package: *
        Pin: release l=systemsmanagement:Uyuni:{{ uyuni_version }}:Debian{{ release }}-Uyuni-Client-Tools
        Pin-Priority: 800

{% endif %} {# grains['os'] == 'Debian' #}
{% endif %} {# no client tools on server or proxy #}
{% endif %} {# uyuni product version or no product version (salt shaker)#}

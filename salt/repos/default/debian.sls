# Defines default repositories for Debian family of distros (Debian/Ubuntu)

{% set release = grains.get('osrelease', None) %}
{% set version = grains.get('product_version', '') %}

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

wait_until_apt_lock_file_unlock:
  cmd.run:
    - name: "test ! -f /var/lib/apt/lists/lock || ! lsof /var/lib/apt/lists/lock"
    - retry:
      - attempts: 10
      - interval: 5
      - until: True

{% if grains['os'] == 'Ubuntu' %}

  {% set short_release = release | replace('.', '') %}

  # We only have one shared Client Tools repository
  {% if 'nightly' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/4.3:/Ubuntu' + release + '-SUSE-Manager-Tools/xUbuntu_' + release %}
  {% elif 'head' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/Ubuntu' + release + '-SUSE-Manager-Tools/xUbuntu_' + release %}
  {% elif 'beta' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS-BETA/x86_64/update/' %}
  {% elif '4.3-released' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
  {% elif '4.3-VM-released' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Ubuntu/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
  {% elif 'uyuni-master' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Master:/Ubuntu' + short_release + '-Uyuni-Client-Tools/xUbuntu_' + release %}
  {% else %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Stable:/Ubuntu' + short_release + '-Uyuni-Client-Tools/xUbuntu_' + release %}
  {% endif %}

{% elif grains['os'] == 'Debian' %}

  # We only have one shared Client Tools repository
  {% if 'nightly' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/4.3:/Debian' + release + '-SUSE-Manager-Tools/Debian_' + release %}
  {% elif 'head' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de", true) + '/ibs/Devel:/Galaxy:/Manager:/Head:/Debian' + release + '-SUSE-Manager-Tools/Debian_' + release %}
  {% elif 'beta' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS-BETA/x86_64/update/' %}
  {% elif '4.3-released' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
  {% elif '4.3-VM-released' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.suse.de/ibs", true) + '/SUSE/Updates/Debian/' + release + '-CLIENT-TOOLS/x86_64/update/' %}
  {% elif 'uyuni-master' in version %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Master:/Debian' + release + '-Uyuni-Client-Tools/Debian_' + release %}
  {% else %}
    {% set tools_repo_url = 'http://' + grains.get("mirror") | default("download.opensuse.org", true) + '/repositories/systemsmanagement:/Uyuni:/Stable:/Debian' + release + '-Uyuni-Client-Tools/Debian_' + release %}
  {% endif %}

{% endif %}

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
    {%- if 'head' in version %}
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:Head:{{ grains['os'] }}{{ release }}-SUSE-Manager-Tools
            Pin-Priority: 800
    {%- elif 'nightly' in version %}
    - contents: |
            Package: *
            Pin: release l=Devel:Galaxy:Manager:4.3:{{ grains['os'] }}{{ release }}-SUSE-Manager-Tools
            Pin-Priority: 800
    {%- elif '4.3-released' in version %}
    - contents: |
            Package: *
            Pin: release l=SUSE:Updates:{{ grains['os'] }}:{{ release }}-CLIENT-TOOLS:x86_64:update
            Pin-Priority: 800
    {%- elif '4.3-VM-released' in version %}
    - contents: |
            Package: *
            Pin: release l=SUSE:Updates:{{ grains['os'] }}:{{ release }}-CLIENT-TOOLS:x86_64:update
            Pin-Priority: 800
    {%- elif 'uyuni-master' in version %}
    - contents: |
            Package: *
            Pin: release l=systemsmanagement:Uyuni:Master:{{ grains['os'] }}{{ short_release }}-Uyuni-Client-Tools
            Pin-Priority: 800
    {%- elif 'uyuni-released' in version %}
    - contents: |
            Package: *
            Pin: release l=systemsmanagement:Uyuni:Stable:{{ grains['os'] }}{{ short_release }}-Uyuni-Client-Tools
            Pin-Priority: 800
    {%- endif %}

remove_no_install_recommends:
  file.absent:
    - name: /etc/apt/apt.conf.d/00InstallRecommends

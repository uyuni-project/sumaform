{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('role') in ['client', 'minion', None] %}

{% if grains['os'] == 'SUSE' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://repos/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

{% elif grains['os_family'] == 'RedHat' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/yum.repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://repos/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

{% elif grains['os_family'] == 'Debian' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/apt/sources.list.d/Devel_Uyuni_BuildRepo.list
    - source: salt://repos/repos.d/Devel_Uyuni_BuildRepo.list
    - template: jinja

{% if grains['os'] == 'Ubuntu' %}
disable_apt_timer:
  service.dead:
    - name: apt-daily.timer
    - enable: False
{% endif %}
{% endif %}
{% endif %}
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

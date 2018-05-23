{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('role') in ['client', 'minion', None] %}
{% if grains['os'] == 'SUSE' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://default/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - file: testsuite_build_repo
      - cmd: refresh_default_repos

{% elif grains['os_family'] == 'RedHat' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/yum.repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://default/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - file: testsuite_build_repo

{% endif %}
{% endif %}
{% endif %}

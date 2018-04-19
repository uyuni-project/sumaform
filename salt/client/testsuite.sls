{% if grains.get('testsuite') | default(false, true) %}

include:
  - client

client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - subscription-tools
      - spacewalk-client-setup
      - spacewalk-check
      - spacewalk-oscap
      - rhncfg-actions
      - openscap-utils
      - man
      - wget
    - require:
      - sls: default

{% if grains['os'] == 'SUSE' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://client/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

refresh_client_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: testsuite_build_repo

suse_client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - openscap-content
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
      {% if '12' in grains['osrelease'] %}
      - aaa_base-extras
      {% endif %}
    - require:
      - cmd: refresh_client_repos

{% elif grains['os_family'] == 'RedHat' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/yum.repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://client/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

res_client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - file: testsuite_build_repo

{% endif %}

{% endif %}

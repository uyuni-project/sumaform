{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('role') in ['client', 'minion', None] %}

{% if grains['os'] == 'SUSE' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://repos/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

refresh_cucumber_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: testsuite_build_repo

{% elif grains['os_family'] == 'RedHat' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/yum.repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://repos/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

{% endif %}
{% endif %}
{% endif %}

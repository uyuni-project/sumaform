{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('role') in ['client', 'minion', None] %}

{% if grains['os'] == 'SUSE' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://repos/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

{% if grains['role'] == 'minion' %}
# Workaround: until `kiwi-desc-saltboot` is part of Manager:tools , we need
# to manually add this repo that contains `kiwi-desc-saltboot`. Can be removed
# when https://github.com/SUSE/spacewalk/issues/5202 is closed

slepos_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_SLEPOS_SUSE-Manager-Retail_Head.repo
    - source: salt://repos/repos.d/Devel_SLEPOS_SUSE-Manager-Retail_Head.repo

{% endif %}

{% elif grains['os_family'] == 'RedHat' %}

testsuite_build_repo:
  file.managed:
    - name: /etc/yum.repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://repos/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

{% endif %}
{% endif %}
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

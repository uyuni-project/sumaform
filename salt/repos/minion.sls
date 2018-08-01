{% if grains.get('role') == 'minion' and grains.get('testsuite') | default(false, true) and grains['os'] == 'SUSE' %}

{% if '12' in grains['osrelease'] %}
containers_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Module-Containers-SLE-12-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-Module-Containers-SLE-12-x86_64-Pool.repo
    - template: jinja

containers_updates_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Module-Containers-SLE-12-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-Module-Containers-SLE-12-x86_64-Update.repo
    - template: jinja

# Workaround: until `kiwi-desc-saltboot` is part of Manager:tools , we need
# to manually add this repo that contains `kiwi-desc-saltboot`. Can be removed
# when https://github.com/SUSE/spacewalk/issues/5202 is closed

slepos_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_SLEPOS_SUSE-Manager-Retail_Head.repo
    - source: salt://repos/repos.d/Devel_SLEPOS_SUSE-Manager-Retail_Head.repo

{% endif %}

{% if '15' in grains['osrelease'] %}
containers_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Module-Containers-SLE-15-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-Module-Containers-SLE-15-x86_64-Pool.repo
    - template: jinja

containers_updates_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Module-Containers-SLE-15-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-Module-Containers-SLE-15-x86_64-Update.repo
    - template: jinja
{% endif %}

{% endif %}

# HACK: work around #10852
default_nop:
  test.nop: []

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

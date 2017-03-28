include:
  - client.repos

{% if grains['os'] == 'SUSE' and grains['osrelease'] == '12.2' and grains['for_testsuite_only'] %}

containers_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Module-Containers-SLE-12-x86_64-Pool.repo
    - source: salt://minion/repos.d/SLE-Module-Containers-SLE-12-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: client.repos

containers_updates_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Module-Containers-SLE-12-x86_64-Update.repo
    - source: salt://minion/repos.d/SLE-Module-Containers-SLE-12-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: client.repos

refresh_minion_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: containers_pool_repo
      - file: containers_updates_repo

{% else %}

no-minion-repos:
  test.nop: []

{% endif %}

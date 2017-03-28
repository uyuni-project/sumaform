include:
  - client.repos

{% if grains['os'] == 'SUSE' and grains['osrelease'] == '12.2' and grains['for_testsuite_only'] %}

containers_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE_Pool_SLE-Module-Containers_12_x86_64.repo
    - source: salt://minion/repos.d/SUSE_Pool_SLE-Module-Containers_12_x86_64.repo
    - template: jinja
    - require:
      - sls: client.repos

containers_updates_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE_Updates_SLE-Module-Containers_12_x86_64.repo
    - source: salt://minion/repos.d/SUSE_Updates_SLE-Module-Containers_12_x86_64.repo
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

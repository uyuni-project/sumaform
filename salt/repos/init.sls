include:
  - repos.controller
  - repos.default
  - repos.evil_minions
  - repos.grafana
  - repos.minion
  - repos.minionswarm
  - repos.suse_manager_proxy
  - repos.suse_manager_server
  - repos.testsuite

{% if grains['os'] == 'SUSE' %}

refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: repos.controller
      - sls: repos.default
      - sls: repos.evil_minions
      - sls: repos.minion
      - sls: repos.minionswarm
      - sls: repos.suse_manager_proxy
      - sls: repos.suse_manager_server
      - sls: repos.testsuite

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

include:
  - repos.default
  - repos.minion
  - repos.suse_manager_proxy
  - repos.suse_manager_server
  - repos.testsuite
  - repos.virthost
  - repos.tools

{% if grains['os'] == 'SUSE' %}
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

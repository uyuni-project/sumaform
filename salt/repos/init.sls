include:
  - repos.disable_local
  - repos.vendor
  {% if not grains.get('additional_repos_only') %}
  - repos.default
  - repos.minion
  - repos.proxy
  - repos.server
  - repos.build_host
  - repos.virthost
  - repos.testsuite
  - repos.tools
  - repos.jenkins
  - repos.server_containerized
  {% endif %}
  - repos.additional

{% if grains['os'] == 'SUSE' %}
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh --force; exit 0
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

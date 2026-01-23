include:
  - repos.disable_local
  - repos.vendor
  {% if not grains.get('additional_repos_only') %}
  - repos.default_settings
  - repos.os
  - repos.client_tools
  - repos.minion
  - repos.proxy
  - repos.proxy_containerized
  - repos.server
  - repos.server_containerized
  - repos.build_host
  - repos.virthost
  - repos.testsuite
  - repos.tools
  - repos.jenkins
  - repos.ruby
  {% endif %}
  - repos.additional

{% if not grains.get('transactional', False) %}
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh --force; exit 0
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

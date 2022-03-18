include:
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
  {% endif %}
  - repos.additional

{% if grains['os'] == 'SUSE' %}
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys --force refresh; exit 0
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

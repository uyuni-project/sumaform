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
  {% endif %}
  - repos.additional

{% if grains['os'] == 'SUSE' %}
refresh_repos:
  cmd.run:
{% if grains['osfullname'] == 'SLE Micro' %}
    - name: transactional-update -c run zypper --non-interactive --gpg-auto-import-keys refresh --force
{% else %}
    - name: zypper --non-interactive --gpg-auto-import-keys refresh --force; exit 0
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

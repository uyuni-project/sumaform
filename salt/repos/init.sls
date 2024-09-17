include:
  - repos.disable_local
  - repos.vendor
  {% if not grains.get('additional_repos_only') %}
  - repos.default_settings
  - repos.os
  - repos.clienttools
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
  {% if '4.3' not in grains.get('product_version', '') %}
  - repos.ruby
  {% endif %}
  {% endif %}
  - repos.additional

{% if grains['os'] == 'SUSE' %}
refresh_repos:
  cmd.run:
{% if grains['osfullname'] in ['SLE Micro', 'SL-Micro'] %}
    - name: transactional-update -c run zypper --non-interactive --gpg-auto-import-keys refresh --force
{% else %}
    - name: zypper --non-interactive --gpg-auto-import-keys refresh --force; exit 0
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

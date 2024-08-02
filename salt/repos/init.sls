include:
  - .disable_local
  - .vendor
  {% if not grains.get('additional_repos_only') %}
  - .default
  - .minion
  - .proxy
  - .server
  - .build_host
  - .virthost
  - .testsuite
  - .tools
  - .jenkins
  - .server_containerized
  - .proxy_containerized
  {% endif %}
  - .additional

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

{% if 'paygo' not in grains.get('product_version') | default('', true) %}
{% if (grains.get('proxy_registration_code') or grains.get('sles_registration_code')) and grains['os'] == 'SUSE' %}
include:
  - scc.clean
  - scc.minion
  - scc.build_host

scc_refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh --force; exit 0
{% endif %}
{% endif %}

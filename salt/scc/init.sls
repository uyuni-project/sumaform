{% if (grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code')) and grains['os'] == 'SUSE' %}
include:
  - scc.clean
  - scc.client
  - scc.minion
  - scc.build_host
  - scc.proxy
  - scc.server

scc_refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh --force; exit 0
{% endif %}

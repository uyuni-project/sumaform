include:
  - sles.repos

{% if '2.1' in grains['version'] %}
suse-manager-proxy-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-2.1-Pool.repo
    - source: salt://suse-manager-proxy/repos.d/SUSE-Manager-Proxy-2.1-Pool.repo
    - template: jinja

suse-manager-proxy-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-2.1-Update.repo
    - source: salt://suse-manager-proxy/repos.d/SUSE-Manager-Proxy-2.1-Update.repo
    - template: jinja
{% endif %}

refresh-suse-manager-proxy-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: sles.repos
      - file: suse-manager-proxy-pool-repo
      - file: suse-manager-proxy-update-repo

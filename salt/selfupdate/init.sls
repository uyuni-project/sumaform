
include:
{% if grains['role'] == 'client' or grains['role'] == 'minion' %}
  - client.repos
{% elif grains['role'] == 'suse-manager-server' %}
- suse-manager.repos
{% elif grains['role'] == 'suse-manager-proxy' %}
- suse-manager-proxy.repos
{% elif grains['role'] == 'control-node' %}
- control-node.repos
{% endif %}

salt-allow-vendor-changes:
  file.managed:
    - name: /etc/zypp/vendors.d/suse
    - makedirs: True
    - contents: |
        [main]
        vendors = SUSE,obs://build.suse.de/Devel:Galaxy:Manager

update-salt:
  pkg.latest:
    - pkgs:
      - salt
      - salt-minion
    - requires:
      - file: salt-allow-vendor-changes

include:
  - suse_manager_proxy.repos
  - suse_manager_proxy.development

{% if '2.1' in grains['version'] %}
# remove SLES product release package, it's replaced by proxy's
sles_release_fix:
  pkg.removed:
    - name: sles-release
    - require:
      - sls: suse_manager_proxy.repos
{% endif %}

proxy-packages:
  pkg.latest:
    {% if 'head' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_Head
    - name: patterns-suma_proxy
    {% elif '3.0-released' in grains['version'] %}
    - fromrepo: SUSE-Manager-Proxy-3.0-x86_64-Pool
    - name: patterns-suma_proxy
    {% elif '3.0-nightly' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_3.0
    - name: patterns-suma_proxy
    {% elif '3.1-released' in grains['version'] %}
    - fromrepo: SUSE-Manager-Proxy-3.1-x86_64-Pool
    - name: patterns-suma_proxy
    {% elif '3.1-nightly' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_3.1
    - name: patterns-suma_proxy
    {% else %}
    - pkgs:
      # proxy
      - suse-manager-proxy-release
      - suse-manager-proxy-release-cd
      - susemanager-proxy
      - spacewalk-client-setup
      - spacewalk-proxy-broker
      - spacewalk-proxy-common
      - spacewalk-proxy-installer
      - spacewalk-proxy-management
      - spacewalk-proxy-package-manager
      - spacewalk-proxy-redirect
      - spacewalk-ssl-cert-check
      - susemanager-tftpsync-recv
      - release-notes-susemanager-proxy
      - supportutils-plugin-susemanager-proxy
      - supportutils-plugin-susemanager-client
      # normal client tools
      - spacewalk-client-tools
      - spacewalk-check
      - spacewalk-client-setup
      - spacewalksd
      - rhnlib
      - suseRegisterInfo
      - zypp-plugin-spacewalk
      - osad
      - rhncfg
      - rhncfg-actions
      - rhncfg-client
      - rhncfg-management
      - rhn-custom-info
      - rhnmd
      - rhnpush
    {% endif %}
    - require:
      - sls: suse_manager_proxy.repos

wget:
  pkg.installed:
    - require:
      - sls: suse_manager_proxy.repos

{% if grains['use_avahi'] %}

squid-configuration-dns-multicast:
  file.replace:
    - name: /usr/share/doc/proxy/conf-template/squid.conf
    - pattern: ^dns_multicast_local .*$
    - repl: dns_multicast_local on
    - append_if_not_found: True
    - require:
      - proxy-packages

squid-configuration-unknown-nameservers:
  file.replace:
    - name: /usr/share/doc/proxy/conf-template/squid.conf
    - pattern: ^ignore_unknown_nameservers .*$
    - repl: ignore_unknown_nameservers off
    - append_if_not_found: True
    - require:
      - proxy-packages

{% endif %}

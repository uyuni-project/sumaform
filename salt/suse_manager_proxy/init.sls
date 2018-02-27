include:
  - suse_manager_proxy.repos
  - suse_manager_proxy.development

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

include:
  - repos
  - proxy.additional_disk
{% if grains['minion'] %}
  - minion
{% endif %}

proxy-packages:
  pkg.installed:
    - pkgs:
{% if grains.get('install_proxy_pattern') %}
      {% if grains['osfullname'] == 'Leap' %}
      - patterns-uyuni_proxy
      {% else %}
      - patterns-suma_proxy
      {% endif %}
{% endif %}
{% if grains.get('osmajorrelease', None)|int() == 15 %}
      - firewalld
{% else %}
      - SuSEfirewall2
{% endif %}
    - require:
      - sls: repos

wget:
  pkg.installed:
    - require:
      - sls: repos

{% if grains['use_avahi'] and grains.get('install_proxy_pattern') %}

squid-configuration-dns-multicast:
  file.replace:
    - name: /usr/share/rhn/proxy-template/squid.conf
    - pattern: ^dns_multicast_local .*$
    - repl: dns_multicast_local on
    - append_if_not_found: True
    - require:
      - proxy-packages

squid-configuration-unknown-nameservers:
  file.replace:
    - name: /usr/share/rhn/proxy-template/squid.conf
    - pattern: ^ignore_unknown_nameservers .*$
    - repl: ignore_unknown_nameservers off
    - append_if_not_found: True
    - require:
      - proxy-packages

{% endif %}


{% if grains.get('auto_register') %}

base_bootstrap_script:
  file.managed:
    - name: /root/bootstrap.sh
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh.sha512
    - mode: 755

bootstrap_script:
  file.replace:
    - name: /root/bootstrap.sh
    - pattern: ^PROFILENAME="".*$
    {% if grains['hostname'] and grains['domain'] %}
    - repl: PROFILENAME="{{ grains['hostname'] }}.{{ grains['domain'] }}"
    {% else %}
    - repl: PROFILENAME="{{grains['fqdn']}}"
    {% endif %}
    - require:
      - file: base_bootstrap_script
  cmd.run:
    - name: /root/bootstrap.sh
    - require:
      - file: bootstrap_script
      - pkg: proxy-packages
      - pkg: wget

{% endif %}


{% if grains.get('download_private_ssl_key') %}

internal-trusted-cert:
  file.managed:
    - name: /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
    - source: http://{{grains['server']}}/pub/RHN-ORG-TRUSTED-SSL-CERT
    - source_hash: http://{{grains['server']}}/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - requires:
      - pkg: proxy-packages

ssl-build-directory:
  file.directory:
    - name: /root/ssl-build

ssl-building-trusted-cert:
  file.managed:
    - name: /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT
    - source: /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
    - requires:
      - file: internal-trusted-cert
      - file: ssl-build-directory

ssl-building-private-ssl-key:
  file.managed:
    - name: /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY
    - source: http://{{grains['server']}}/pub/RHN-ORG-PRIVATE-SSL-KEY
    - source_hash: http://{{grains['server']}}/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - requires:
      - pkg: proxy-packages
      - file: ssl-build-directory

ssl-building-ca-configuration:
  file.managed:
    - name: /root/ssl-build/rhn-ca-openssl.cnf
    - source: http://{{grains['server']}}/pub/rhn-ca-openssl.cnf
    - source_hash: http://{{grains['server']}}/pub/rhn-ca-openssl.cnf.sha512
    - requires:
      - pkg: proxy-packages
      - file: ssl-build-directory

{% endif %}

{% if grains.get('auto_configure') %}

/root/config-answers.txt:
  file.managed:
    - source: salt://proxy/config-answers.txt
    - template: jinja

configure-proxy:
  cmd.run:
    - name: configure-proxy.sh --non-interactive --rhn-user={{ grains.get('server_username') | default('admin', true) }} --rhn-password={{ grains.get('server_password') | default('admin', true) }} --answer-file=/root/config-answers.txt ; true
    - env:
      - SSL_PASSWORD: spacewalk
    - creates: /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT
    - requires:
      - pkg: proxy-packages
      - file: /root/config-answers.txt
      - file: ssl-building-trusted-cert
      - file: ssl-building-private-ssl-key
      - file: ssl-building-ca-configuration

{% endif %}

{% if grains.get('generate_bootstrap_script') %}

create_bootstrap_script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-DEFAULT --no-up2date --hostname {{ grains['hostname'] }}.{{ grains['domain'] }} --traditional
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh
    - require:
      - cmd: configure-proxy

create_bootstrap_script_md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap.sh > /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - require:
      - cmd: create_bootstrap_script

ca_cert_checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT > /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - cmd: configure-proxy

{% endif %}

{% if grains.get('publish_private_ssl_key') %}

private-ssl-key:
  file.copy:
    - name: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY
    - source: /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY
    - mode: 644
    - require:
      - file: ssl-building-private-ssl-key

private-ssl-key-checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY > /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - require:
      - file: private-ssl-key

ca-configuration:
  file.copy:
    - name: /srv/www/htdocs/pub/rhn-ca-openssl.cnf
    - source: /root/ssl-build/rhn-ca-openssl.cnf
    - mode: 644
    - require:
      - file: ssl-building-ca-configuration

ca-configuration-checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/rhn-ca-openssl.cnf > /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - creates: /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - require:
      - file: ca-configuration

{% endif %}


# WORKAROUND: this avoids already established connections to hang
# when SuSEfirewall2 is started by the retail formula
# (see bsc#1135303)
preload_conntrack_modules_and_enable_them_at_boottime:
  file.managed:
    - name: /etc/modules-load.d/nf_conntrack.conf
    - content: |
{% if salt['pkg.version_cmp'](grains['kernelrelease'],'4.19') < 0 %}
        nf_conntrack_ipv4
        nf_conntrack_ipv6
{% endif %}
        nf_conntrack
    - require:
      - pkg: proxy-packages
  cmd.run:
{% if salt['pkg.version_cmp'](grains['kernelrelease'],'4.19') < 0 %}
    - name: modprobe nf_conntrack_ipv4 && modprobe nf_conntrack_ipv6
{% else %}
    - name: modprobe nf_conntrack
{% endif %}
    - require:
      - pkg: proxy-packages

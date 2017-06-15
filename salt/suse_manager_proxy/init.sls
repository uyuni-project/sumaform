include:
  - suse_manager_proxy.repos

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
    - repl: PROFILENAME="{{grains['fqdn']}}"
    - require:
      - file: base_bootstrap_script
  cmd.run:
    - name: /root/bootstrap.sh
    - require:
      - file: bootstrap_script
      - pkg: proxy-packages
      - pkg: wget

/root/config-answers.txt:
  file.managed:
    - source: salt://suse_manager_proxy/config-answers.txt
    - template: jinja

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

configure-proxy:
  cmd.run:
    - name: configure-proxy.sh --non-interactive --rhn-user=admin --rhn-password=admin --answer-file=/root/config-answers.txt ; true
    - env:
      - SSL_PASSWORD: spacewalk
    - creates: /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT
    - requires:
      - pkg: proxy-packages
      - file: /root/config-answers.txt
      - file: ssl-building-trusted-cert
      - file: ssl-building-private-ssl-key
      - file: ssl-building-ca-configuration

create_bootstrap_script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-DEFAULT --no-up2date {{ '--traditional' if '2.1' not in grains['version'] and '3.0' not in grains['version'] else '' }}
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

private-ssl-key:
  file.copy:
    - name: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY
    - source: /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY
    - mode: 644

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

ca-configuration-checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/rhn-ca-openssl.cnf > /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - creates: /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - require:
      - file: ca-configuration

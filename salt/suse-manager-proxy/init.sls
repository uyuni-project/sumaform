include:
  - suse-manager-proxy.repos

{% if '2.1' in grains['version'] %}
# remove SLES product release package, it's replaced by proxy's
sles-release:
  pkg.removed:
    - require:
      - sls: suse-manager-proxy.repos
{% endif %}

proxy-packages:
  pkg.latest:
    {% if '3-stable' in grains['version'] %}
    - fromrepo: SUSE-Manager-Proxy-3.0-x86_64-Pool
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
      - sls: suse-manager-proxy.repos

wget:
  pkg.installed:
    - require:
      - sls: suse-manager-proxy.repos

bootstrap-script:
  file.managed:
    - name: /root/bootstrap.sh
    - source: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh
    - source_hash: http://{{grains['server']}}/pub/bootstrap/bootstrap.sh.sha512
    - mode: 755
  cmd.run:
    - name: /root/bootstrap.sh
    - require:
      - file: bootstrap-script
      - pkg: proxy-packages
      - pkg: wget

/root/config-answers.txt:
  file.managed:
    - source: salt://suse-manager-proxy/config-answers.txt
    - template: jinja

shared-trusted-cert:
  file.managed:
    - name: /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
    - source: http://{{grains['server']}}/pub/RHN-ORG-TRUSTED-SSL-CERT
    - source_hash: http://{{grains['server']}}/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - requires:
      - pkg: proxy-packages

ssl-build-directory:
  file.directory:
    - name: /root/ssl-build

trusted-cert:
  file.managed:
    - name: /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT
    - source: /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
    - requires:
      - file: shared-trusted-cert
      - file: ssl-build-directory

private-ssl-key:
  file.managed:
    - name: /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY
    - source: http://{{grains['server']}}/pub/RHN-ORG-PRIVATE-SSL-KEY
    - source_hash: http://{{grains['server']}}/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - requires:
      - pkg: proxy-packages
      - file: ssl-build-directory

ca-configuration:
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
      - file: trusted-cert
      - file: private-ssl-key
      - file: ca-configuration

create-bootstrap-script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-DEFAULT --no-up2date
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh
    - require:
      - cmd: configure-proxy

create-bootstrap-script-md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap.sh > /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - require:
      - cmd: create-bootstrap-script

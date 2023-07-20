include:
  - scc.server
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  - server.additional_disk
  - server.firewall
  {% if grains.get('db_configuration')['local'] %}
  - server.postgres
  {% endif %}
  - server.prometheus
  - server.tomcat
  - server.taskomatic
  - server.spacewalk-search
  - server.rhn
  - server.initial_content
  - server.iss
  - server.testsuite
  - server.salt_master
  - server.tcpdump
  - doesnot.exist

{% if 'uyuni' not in grains.get('product_version') %}
server-switch-product:
  cmd.run:
    - name: zypper --non-interactive in -t product --force-resolution --auto-agree-with-product-licenses SUSE-Manager-Server
    - require:
      - sls: repos
{% endif %}

server_packages:
  pkg.installed:
    - refresh: True
    {% if grains['osfullname'] == 'Leap' %}
    - name: patterns-uyuni_server
    {% else %}
    - name: patterns-suma_server
    {% endif %}
    - require:
      {% if 'build_image' not in grains.get('product_version') | default('', true) %}
      - sls: repos
      {% endif %}
      - sls: server.firewall

{% if 'minion' in grains.get('roles') and grains.get('server') and grains.get('download_private_ssl_key') %}

ssl-build-directory:
  file.directory:
    - name: /root/ssl-build

ssl-building-trusted-cert:
  file.managed:
    - name: /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT
    - source: http://{{grains['server']}}/pub/RHN-ORG-TRUSTED-SSL-CERT
    - source_hash: http://{{grains['server']}}/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - file: ssl-build-directory

ssl-building-private-ssl-key:
  file.managed:
    - name: /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY
    - source: http://{{grains['server']}}/pub/RHN-ORG-PRIVATE-SSL-KEY
    - source_hash: http://{{grains['server']}}/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - require:
      - file: ssl-build-directory

ssl-building-ca-configuration:
  file.managed:
    - name: /root/ssl-build/rhn-ca-openssl.cnf
    - source: http://{{grains['server']}}/pub/rhn-ca-openssl.cnf
    - source_hash: http://{{grains['server']}}/pub/rhn-ca-openssl.cnf.sha512
    - require:
      - file: ssl-build-directory

{% endif %}


{% if '4' in grains['product_version'] and grains['osfullname'] != 'Leap' and not grains.get('server_registration_code') and 'build_image' not in grains.get('product_version') %}
product_package_installed:
   cmd.run:
     - name: zypper --non-interactive install --auto-agree-with-licenses --force-resolution -t product SUSE-Manager-Server
{% endif %}

environment_setup_script:
  file.managed:
    - name: /root/setup_env.sh
    - source: salt://server/setup_env.sh
    - template: jinja

{% if not grains.get('db_configuration')['local'] and grains.get('provider') == 'aws' %}
aws_db-certificate:
  file.managed:
    - name: /root/aws.crt
    - source: salt://server/aws.crt
    - template: jinja
{% endif %}

server_setup:
  cmd.run:
    - name: /usr/lib/susemanager/bin/mgr-setup -l /var/log/susemanager_setup.log -s
    - creates: /root/.MANAGER_SETUP_COMPLETE
    - require:
      - pkg: server_packages
      - file: environment_setup_script

ca_cert_checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT > /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - cmd: server_setup

no_motd:
  file.absent:
    - name: /etc/motd
    - require:
      - cmd: server_setup

{% if grains.get('from_email') %}
substitute_email_sender_address:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: web.default_mail_from.*
    - repl: web.default_mail_from = {{ grains['from_email'] }}
    - require:
        - cmd: server_setup
{% endif %}

{% if grains.get('accept_all_ssl_protocols') %}
server_substitute_sslprotocols:
  file.replace:
    - name: /etc/apache2/ssl-global.conf
    - pattern: SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    - repl: SSLProtocol all -SSLv2 -SSLv3
    - require:
        - cmd: server_setup
{% endif %}

{% if grains.get('traceback_email') %}
substitute_email_traceback_address:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: traceback_mail.*
    - repl: traceback_mail = {{ grains['traceback_email'] }}
    - require:
        - cmd: server_setup
{% endif %}

{% if grains.get('login_timeout') %}
extend_login_timeout:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: web.session_database_lifetime.*
    - repl: web.session_database_lifetime = {{ grains['login_timeout'] }}
    - append_if_not_found: True
    - require:
        - cmd: server_setup
{% endif %}

# WORKAROUND: 4.4 is needed only until the branching of SUSE Manager 4.4 is completed
{% if 'head' in grains.get('product_version') or '4.4' in grains.get('product_version') %}
change_product_tree_to_beta:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: java.product_tree_tag = .*\n
    - repl: java.product_tree_tag = Beta
    - append_if_not_found: True
    - require:
      - cmd: server_setup
{% endif %}

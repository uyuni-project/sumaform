include:
  - repos
  - server.additional_disk
  - server.firewall
  - server.postgres
  - server.tomcat
  - server.taskomatic
  - server.spacewalk-search
  - server.rhn
  - server.prometheus
  - server.initial_content
  - server.iss
  - server.testsuite
  - server.pts
  - server.salt_master
  - server.tcpdump
  - server.release-notes-workaround

server_packages:
  pkg.installed:
    - refresh: True
    {% if grains['osfullname'] == 'Leap' %}
    - name: patterns-uyuni_server
    {% else %}
    - name: patterns-suma_server
    {% endif %}
    - require:
      - sls: repos
      - sls: server.firewall

{% if '4' in grains['product_version'] and grains['osfullname'] != 'Leap' %}
product_package_installed:
   cmd.run:
     - name: zypper --non-interactive install --auto-agree-with-licenses --force-resolution -t product SUSE-Manager-Server
{% endif %}

environment_setup_script:
  file.managed:
    - name: /root/setup_env.sh
    - source: salt://server/setup_env.sh
    - template: jinja

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

{% if grains.get('traceback_email') %}
substitute_email_traceback_address:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: traceback_mail.*
    - repl: traceback_mail = {{ grains['traceback_email'] }}
    - require:
        - cmd: server_setup
{% endif %}

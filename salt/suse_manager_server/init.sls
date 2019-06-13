include:
  - repos
  - suse_manager_server.firewall
  - suse_manager_server.postgres
  - suse_manager_server.tomcat
  - suse_manager_server.taskomatic
  - suse_manager_server.spacewalk-search
  - suse_manager_server.rhn
  - suse_manager_server.prometheus
  - suse_manager_server.initial_content
  - suse_manager_server.iss
  - suse_manager_server.testsuite
  - suse_manager_server.pts
  - suse_manager_server.filebeat
  - suse_manager_server.salt_master
  - suse_manager_server.apparmor
  - suse_manager_server.tcpdump

# HACK: make sure we do not run into a JVM bug in the openSUSE 42.3 outdated package
{% if grains['osfullname'] == 'Leap' and grains['osrelease'] == '42.3' %}
java-1_8_0-openjdk-headless:
  pkg.latest:
    - require:
      - sls: repos
{% endif %}

suse_manager_packages:
  pkg.latest:
    - refresh: True
    {% if grains['osfullname'] == 'Leap' %}
    - name: patterns-uyuni_server
    {% else %}
    - name: patterns-suma_server
    {% endif %}
    - require:
      - sls: repos
      - sls: suse_manager_server.firewall

environment_setup_script:
  file.managed:
    - name: /root/setup_env.sh
    - source: salt://suse_manager_server/setup_env.sh
    - template: jinja

suse_manager_setup:
  cmd.run:
    - name: /usr/lib/susemanager/bin/migration.sh -l /var/log/susemanager_setup.log -s
    - creates: /root/.MANAGER_SETUP_COMPLETE
    - require:
      - pkg: suse_manager_packages
      - file: environment_setup_script
      {% if grains.get('apparmor') %}
      - sls: suse_manager_server.apparmor
      {% endif %}

ca_cert_checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT > /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - cmd: suse_manager_setup

no_motd:
  file.absent:
    - name: /etc/motd
    - require:
      - cmd: suse_manager_setup

{% if grains.get('from_email') %}
substitute_email_sender_address:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: web.default_mail_from.*
    - repl: web.default_mail_from = {{ grains['from_email'] }}
    - require:
        - cmd: suse_manager_setup
{% endif %}

{% if grains.get('traceback_email') %}
substitute_email_traceback_address:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: traceback_mail.*
    - repl: traceback_mail = {{ grains['traceback_email'] }}
    - require:
        - cmd: suse_manager_setup
{% endif %}

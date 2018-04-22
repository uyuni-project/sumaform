include:
  - suse_manager_server.repos
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

suse_manager_packages:
  pkg.latest:
    {% if 'head' in grains['version'] or 'test' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_Head
    {% elif '3.0-released' in grains['version'] %}
    - fromrepo: SUSE-Manager-3.0-x86_64-Pool
    {% elif '3.0-nightly' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_3.0
    {% elif '3.1-released' in grains['version'] %}
    - fromrepo: SUSE-Manager-3.1-x86_64-Pool
    {% elif '3.1-nightly' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_3.1
    {% endif %}
    - name: patterns-suma_server
    - require:
      - sls: suse_manager_server.repos
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

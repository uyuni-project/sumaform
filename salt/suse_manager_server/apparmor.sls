{% if grains.get('apparmor') and grains['os'] == 'SUSE' %}

apparmor_packages:
  pkg.installed:
    - pkgs:
      - apparmor-parser
      - apparmor-profiles
      - apparmor-utils
      - audit

auditd:
  service.running:
    - enable: True
    - running: True
    - require:
      - pkg: apparmor_packages


# /usr/sbin/httpd-prefork started by apache2 service

apparmor_httpdprefork_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.sbin.httpd-prefork
    - source: salt://suse_manager_server/apparmor.d/usr.sbin.httpd-prefork

apparmor_httpdprefork_complain_mode:
  cmd.run:
    - name: aa-complain /usr/sbin/httpd-prefork
    - require:
      - service: auditd
      - file: apparmor_httpdprefork_profile


# /usr/sbin/rhn-search (bash script) started by rhn-search service

apparmor_rhnsearch_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.sbin.rhn-search
    - source: salt://suse_manager_server/apparmor.d/usr.sbin.rhn-search

apparmor_rhnsearch_complain_mode:
  cmd.run:
    - name: aa-complain /usr/sbin/rhn-search
    - require:
      - service: auditd
      - file: apparmor_rhnsearch_profile


# /usr/sbin/taskomatic (bash script) started by taskomatic service

apparmor_taskomatic_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.sbin.taskomatic
    - source: salt://suse_manager_server/apparmor.d/usr.sbin.taskomatic

apparmor_taskomatic_complain_mode:
  cmd.run:
    - name: aa-complain /usr/sbin/taskomatic
    - require:
      - service: auditd
      - file: apparmor_taskomatic_profile


# /usr/lib/postgresql96/bin/postgres started by postgresql service

apparmor_postgres_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.lib.postgresql96.bin.postgres
    - source: salt://suse_manager_server/apparmor.d/usr.lib.postgresql96.bin.postgres

apparmor_postgres_complain_mode:
  cmd.run:
    - name: aa-complain /usr/lib/postgresql96/bin/postgres
    - require:
      - service: auditd
      - file: apparmor_postgres_profile


# /usr/lib/tomcat/server (bash script) started by tomcat service

apparmor_tomcatserver_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.lib.tomcat.server
    - source: salt://suse_manager_server/apparmor.d/usr.lib.tomcat.server

apparmor_tomcatserver_complain_mode:
  cmd.run:
    - name: aa-complain /usr/lib/tomcat/server
    - require:
      - service: auditd
      - file: apparmor_tomcatserver_profile


# /usr/bin/salt-master (python script) started by salt-master service

apparmor_saltmaster_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.bin.salt-master
    - source: salt://suse_manager_server/apparmor.d/usr.bin.salt-master

apparmor_saltmaster_complain_mode:
  cmd.run:
    - name: aa-complain /usr/bin/salt-master
    - require:
      - service: auditd
      - file: apparmor_saltmaster_profile


# /usr/bin/coblerd (python script) started by cobblerd service

apparmor_cobblerd_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.bin.cobblerd
    - source: salt://suse_manager_server/apparmor.d/usr.bin.cobblerd

apparmor_cobblerd_complain_mode:
  cmd.run:
    - name: aa-complain /usr/bin/cobblerd
    - require:
      - service: auditd
      - file: apparmor_cobblerd_profile

{% endif %}

firewalld:
  service.dead:
    - enable: False

spacewalk-repo:
    file.recurse:
    - name: /etc/yum.repos.d
    - source: salt://spacewalk/yum.repos.d
    - template: jinja

jpackage-repo:
  pkgrepo.managed:
    - name: jpackage-generic
    - humanname: JPackage generic
    - mirrorlist: http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=5.0
    - comments:
        - '#http://mirrors.dotsrc.org/pub/jpackage/5.0/generic/free/'
    - enabled: True
    - gpgcheck: 1
    - gpgkey: http://www.jpackage.org/jpackage.asc

spacewalk-packages:
  pkg.installed:
    - names:
      - spacewalk-setup-postgresql
      - spacewalk-postgresql
      - spacewalk-utils
      - polkit
    - require:
      - file: spacewalk-repo
      - pkgrepo: jpackage-repo

answer-file:
  file.managed:
    - name: /etc/rhn/spacewalk-setup-answer
    - source: salt://spacewalk/spacewalk-setup-answer

spacewalk-setup:
  cmd.run:
    - name: spacewalk-setup --answer-file=/etc/rhn/spacewalk-setup-answer
    - creates: /var/log/rhn/rhn_installation.log
    - require:
      - pkg: spacewalk-postgresql
      - file: answer-file

/etc/sysconfig/tomcat:
  file.replace:
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \1"'
    - require:
      - cmd: spacewalk-setup

tomcat:
  service.running:
    - watch:
      - file: /etc/sysconfig/tomcat
    - require:
      - file: /etc/sysconfig/tomcat

taskomatic-config:
  file.append:
    - name: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - text: ['wrapper.java.additional.3=-Xdebug',
             'wrapper.java.additional.4=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n']
    - require:
      - cmd: spacewalk-setup

taskomatic:
  service.running:
    - watch:
      - file: taskomatic-config
    - require:
      - file: taskomatic-config

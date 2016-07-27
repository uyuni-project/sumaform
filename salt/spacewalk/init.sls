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

/etc/rhn/spacewalk-setup-answer:
  file.managed:
    - source: salt://spacewalk/spacewalk-setup-answer

setup spacewalk:
  cmd.run:
    - name: spacewalk-setup --answer-file=/etc/rhn/spacewalk-setup-answer
    - creates: /var/log/rhn/rhn_installation.log
    - require:
      - pkg: spacewalk-postgresql
      - file: /etc/rhn/spacewalk-setup-answer

/etc/sysconfig/tomcat:
  file.replace:
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \1"'
    - require:
      - cmd: "setup spacewalk"

tomcat:
  service.running:
    - watch:
      - file: /etc/sysconfig/tomcat
    - require:
      - file: /etc/sysconfig/tomcat

/usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf:
  file.append:
    - text: ['wrapper.java.additional.3=-Xdebug',
             'wrapper.java.additional.4=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n']
    - require:
      - cmd: "setup spacewalk"

taskomatic:
  service.running:
    - watch:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - require:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf

# Enable debugging port on Tomcat

{% if grains['role'] == 'suse-manager-server' and '2.1' in grains['version'] %}

/etc/init.d/tomcat6:
  file.patch:
    - source: salt://development-settings/tomcat6.patch
    - hash: md5=bfebb4990690961e435d650009ec4f9f
    - require:
      - cmd: default bootstrap script

/etc/tomcat6/tomcat6.conf:
  file.append:
    - text: "JAVA_OPTS=\"$JAVA_OPTS
          -Xdebug
          -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n
          -Dcom.sun.management.jmxremote.port=3333
          -Dcom.sun.management.jmxremote.ssl=false
          -Dcom.sun.management.jmxremote.authenticate=false
          -Djava.rmi.server.hostname={{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
        \""
    - require:
      - file: /etc/init.d/tomcat6

tomcat6:
  service.running:
    - watch:
      - file: /etc/rhn/rhn.conf
      - file: /etc/tomcat6/tomcat6.conf
    - require:
      - file: /etc/rhn/rhn.conf
      - file: /etc/tomcat6/tomcat6.conf

speed up refresh after deploy:
  file.replace:
    - name: /etc/apache2/conf.d/zz-spacewalk-www.conf
    - pattern: 'ProxySet min=1\n'
    - repl: 'ProxySet min=1 retry=0\n'
    - require:
      - cmd: default bootstrap script

apache2:
  service.running:
    - watch:
      - service: tomcat6
      - file: speed up refresh after deploy
    - require:
      - service: tomcat6
      - file: speed up refresh after deploy

/usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf:
  file.append:
    - text: ['wrapper.java.additional.7=-Xdebug',
             'wrapper.java.additional.8=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n']

taskomatic:
  service.running:
    - watch:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - require:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf

{% elif grains['role'] == 'suse-manager-server' and ('3' in grains['version'] or 'head' in grains['version']) %}

/etc/tomcat/tomcat.conf:
  file.replace:
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \1"'
    - require:
      - cmd: default activation key

tomcat:
  service.running:
    - watch:
      - file: /etc/tomcat/tomcat.conf
    - require:
      - file: /etc/tomcat/tomcat.conf

/usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf:
  file.append:
    - text: ['wrapper.java.additional.7=-Xdebug',
             'wrapper.java.additional.8=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n']

taskomatic:
  service.running:
    - watch:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - require:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf

{% elif grains['role'] == 'spacewalk-server' %}

/etc/sysconfig/tomcat:
  file.replace:
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \1"'
    - require:
      - sls: spacewalk

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

taskomatic:
  service.running:
    - watch:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
    - require:
      - file: /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf

{% endif %}

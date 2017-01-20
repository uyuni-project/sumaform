{% if grains['for-development-only'] %}

include:
  - suse-manager.rhn

{% if '2.1' in grains['version'] %}

tomcat6-init-script:
  file.patch:
    - name: /etc/init.d/tomcat6
    - source: salt://suse-manager/tomcat6.patch
    - hash: md5=bfebb4990690961e435d650009ec4f9f
    - require:
      - sls: suse-manager.rhn

tomcat6-config:
  file.append:
    - name: /etc/tomcat6/tomcat6.conf
    - text: "JAVA_OPTS=\"$JAVA_OPTS
          -Xdebug
          -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n
          -Dcom.sun.management.jmxremote.port=3333
          -Dcom.sun.management.jmxremote.ssl=false
          -Dcom.sun.management.jmxremote.authenticate=false
          -Djava.rmi.server.hostname={{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
        \""
    - require:
      - file: tomcat6-init-script

tomcat6:
  service.running:
    - watch:
      - file: tomcat6-config
    - require:
      - file: tomcat6-config

refresh-after-deploy-speedup-config:
  file.replace:
    - name: /etc/apache2/conf.d/zz-spacewalk-www.conf
    - pattern: 'ProxySet min=1\n'
    - repl: 'ProxySet min=1 retry=0\n'
    - require:
      - sls: suse-manager.rhn

apache2:
  service.running:
    - watch:
      - service: tomcat6
      - file: refresh-after-deploy-speedup-config
    - require:
      - service: tomcat6
      - file: refresh-after-deploy-speedup-config

{% else %}

tomcat-config:
  file.replace:
    - name: /etc/tomcat/tomcat.conf
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \1"'
    - require:
      - sls: suse-manager.rhn

{% if 'head' in grains['version'] %}
tomcat-config-loaded:
  file.comment:
    - name: /etc/tomcat/tomcat.conf
    - regex: '^TOMCAT_CFG_LOADED.*'
    - require:
      - sls: suse-manager.rhn
{% endif %}

tomcat:
  service.running:
    - watch:
      - file: tomcat-config
    - require:
      - file: tomcat-config

{% endif %}

{% endif %}

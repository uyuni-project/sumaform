{% if grains['for_development_only'] %}

include:
  - suse_manager_server.rhn

{% if '2.1' in grains['version'] %}

tomcat6_init_script:
  file.patch:
    - name: /etc/init.d/tomcat6
    - source: salt://suse_manager_server/tomcat6.patch
    - hash: md5=bfebb4990690961e435d650009ec4f9f
    - require:
      - sls: suse_manager_server.rhn

tomcat6_config:
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
      - file: tomcat6_init_script

tomcat6:
  service.running:
    - watch:
      - file: tomcat6_config
    - require:
      - file: tomcat6_config

refresh_after_deploy_speedup_config:
  file.replace:
    - name: /etc/apache2/conf.d/zz-spacewalk-www.conf
    - pattern: 'ProxySet min=1\n'
    - repl: 'ProxySet min=1 retry=0\n'
    - require:
      - sls: suse_manager_server.rhn

apache2:
  service.running:
    - watch:
      - service: tomcat6
      - file: refresh_after_deploy_speedup_config
    - require:
      - service: tomcat6
      - file: refresh_after_deploy_speedup_config

{% else %}

tomcat_config:
  file.replace:
    - name: /etc/tomcat/tomcat.conf
    - pattern: 'JAVA_OPTS="(?!-Xdebug)(.*)"'
    - repl: 'JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \1"'
    - require:
      - sls: suse_manager_server.rhn

{% if 'head' in grains['version'] %}
tomcat_config_loaded:
  file.comment:
    - name: /etc/tomcat/tomcat.conf
    - regex: '^TOMCAT_CFG_LOADED.*'
    - require:
      - sls: suse_manager_server.rhn
{% endif %}

tomcat:
  service.running:
    - watch:
      - file: tomcat_config
    - require:
      - file: tomcat_config

{% endif %}

{% endif %}

include:
  - server_containerized

tomcat_scc_access_logging:
  file.line:
    - name: /usr/share/susemanager/www/tomcat/webapps/rhn/WEB-INF/classes/log4j2.xml
    - content: '        <Logger name="com.suse.scc.client.SCCWebClient" level="info" />'
    - after: "<Loggers>"
    - mode: ensure
    - require:
      - sls: server_containerized

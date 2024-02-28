include:
  - server_containerized

taskomatic_scc_access_logging:
  file.line:
    - name: /usr/share/rhn/classes/log4j2.xml
    - content: '        <Logger name="com.suse.scc.client.SCCWebClient" level="info" />'
    - after: "<Loggers>"
    - mode: ensure
    - require:
      - sls: server_containerized

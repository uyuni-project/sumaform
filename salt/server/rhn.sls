include:
  - server

get_rhn_conf:
  manage_config.manage_lines:
    - name: |
        /etc/rhn/rhn.conf
    - key_value:
        {% if grains.get('skip_changelog_import') %}
        package_import_skip_changelog: 1
        {% endif %}
        java.max_changelog_entries: 3
        {% if grains.get('disable_download_tokens') %}
        ava.salt_check_download_tokens: false
        {% endif %}
        {% if grains.get('monitored') | default(false, true) %}
        prometheus_monitoring_enabled: true
        {% endif %}
        {% if not grains.get('forward_registration') | default(false, true) %}
        server.susemanager.forward_registration: 0
        {% endif %}
        {% if grains.get('c3p0_connection_timeout') | default(true, false) %}
        hibernate.c3p0.unreturnedConnectionTimeout: {{ grains.get('c3p0_connection_timeout') | default(14400, true) }}
        {% endif %}
        {% if grains.get('disable_auto_bootstrap') | default(false, true) %}
        server.susemanager.auto_generate_bootstrap_repo: 0
        {% endif %}
    - require:
      - sls: server

{%- set mirror_hostname = grains.get('server_mounted_mirror') if grains.get('server_mounted_mirror') else grains.get('mirror') %}

{% if mirror_hostname %}

nfs_client:
  pkg.installed:
    - name: nfs-client

non_empty_fstab:
  file.managed:
    - name: /etc/fstab
    - replace: false

mirror_directory:
  mount.mounted:
    - name: /mirror
    - device: {{ mirror_hostname }}:/srv/mirror
    - fstype: nfs
    - mkmnt: True
    - require:
      - file: /etc/fstab
      - pkg: nfs_client

rhn_conf_from_dir:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: "^server.susemanager.fromdir *=.*"
    - repl: server.susemanager.fromdir = /mirror
    - append_if_not_found: True
    - require:
      - sls: server
      - mount: mirror_directory

{% elif salt["grains.get"]("smt") %}

rhn_conf_mirror:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: "^server.susemanager.mirror *=.*"
    - repl: server.susemanager.mirror = {{ salt["grains.get"]("smt") }}
    - append_if_not_found: True
    - require:
      - sls: server

{% endif %}


{% if grains.get('c3p0_connection_debug') | default(false, true) %}

rhn_conf_c3p0_connection_debug:
  file.repl:
    - name: /etc/rhn/rhn.conf
    - pattern: "^hibernate.c3p0.debugUnreturnedConnectionStackTraces *=.*"
    - repl: hibernate.c3p0.debugUnreturnedConnectionStackTraces = true
    - append_if_not_found: True
    - require:
      - sls: server

rhn_conf_c3p0_connection_debug_log:
  file.line:
    - name: /srv/tomcat/webapps/rhn/WEB-INF/classes/log4j2.xml
    - content: '    <Logger name="com.mchange.v2.resourcepool.BasicResourcePool" level="info" />'
    - after: "<Loggers>"
    - mode: ensure
    - require:
      - sls: server

{% endif %}

# catch-all to ensure we always have at least one state covering /etc/rhn/rhn.conf
rhn_conf_present:
  file.touch:
    - name: /etc/rhn/rhn.conf

include:
  - server

{% if grains.get('skip_changelog_import') %}

package_import_skip_changelog_reposync:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: package_import_skip_changelog = 1
    - require:
      - sls: server

{% endif %}

{% if 'uyuni' in grains['product_version'] %}

limit_changelog_entries:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: java.max_changelog_entries = 3
    - require:
      - sls: server

{% endif %}

{% if grains.get('disable_download_tokens') %}
disable_download_tokens:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: java.salt_check_download_tokens = false
    - require:
      - sls: server
{% endif %}

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
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: server.susemanager.fromdir = /mirror
    - require:
      - sls: server
      - mount: mirror_directory

{% elif salt["grains.get"]("smt") %}

rhn_conf_mirror:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: server.susemanager.mirror = {{ salt["grains.get"]("smt") }}
    - require:
      - sls: server

{% endif %}

{% if grains.get('monitored') | default(false, true) %}

rhn_conf_prometheus:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: prometheus_monitoring_enabled = true
    - require:
      - sls: server

{% endif %}

{% if not grains.get('forward_registration') | default(false, true) %}

rhn_conf_forward_reg:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: server.susemanager.forward_registration = 0
    - require:
      - sls: server

{% endif %}

{% if grains.get('c3p0_connection_timeout') | default(true, false) %}

rhn_conf_c3p0_connection_timeout:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: hibernate.c3p0.unreturnedConnectionTimeout = {{ grains.get('c3p0_connection_timeout') | default(14400, true) }}
    - require:
      - sls: server

{% endif %}

{% if grains.get('c3p0_connection_debug') | default(false, true) %}

rhn_conf_c3p0_connection_debug:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: hibernate.c3p0.debugUnreturnedConnectionStackTraces = true
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

{% if grains.get('disable_auto_bootstrap') | default(false, true) %}

rhn_conf_disable_auto_generate_bootstrap_repo :
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: server.susemanager.auto_generate_bootstrap_repo = 0
    - require:
      - sls: server

{% endif %}

# catch-all to ensure we always have at least one state covering /etc/rhn/rhn.conf
rhn_conf_present:
  file.touch:
    - name: /etc/rhn/rhn.conf

write_rhn_conf:
  manage_config.manage_lines:
    - name: |
        /etc/rhn/rhn.conf
    - container_cmd: "mgrctl exec"
    - key_value:
        {% if grains.get('skip_changelog_import') %}
        package_import_skip_changelog: 1
        {% endif %}

        java.max_changelog_entries: 3

        {% if grains.get('disable_download_tokens') %}
        java.salt_check_download_tokens: false
        {% endif %}

        {% if grains.get('monitored') | default(false, true) %}
        prometheus_monitoring_enabled: true
        {% endif %}

        {% if not grains.get('forward_registration') | default(false, true) %}
        server.susemanager.forward_registration: 0
        {% endif %}

        {% if grains.get('disable_auto_bootstrap') | default(true, true) %}
        server.susemanager.auto_generate_bootstrap_repo: 0
        {% endif %}

        {% if 'head' in grains.get('product_version', '') and grains.get('beta_enabled') %}
        java.product_tree_tag: 0
        {% endif %}

        {% if grains.get('testsuite') | default(false, true) %}
        java.salt_presence_ping_timeout: 6
        {% endif %}

        # see https://documentation.suse.com/multi-linux-manager/5.1/en/docs/administration/auditing.html#_oval
        {% if grains.get('enable_oval_metadata') | default(false, true) %}
        java.cve_audit.enable_oval_metadata: true
        {% endif %}


{% if 'nightly' in grains.get('product_version', '') %}
change_web_version:
  cmd.run:
    - name: |
        PRODUCT_VERSION=$(mgrctl exec "cat /etc/susemanager-release | awk -F'[()]' '{print \$2}'")
        BUILD_DATE=$(date +%Y%m%d)
        FULL_VERSION="${PRODUCT_VERSION}.${BUILD_DATE}"
        mgrctl exec "grep -q \"web.version\" /etc/rhn/rhn.conf && sed -i \"s/web.version.*/web.version = ${FULL_VERSION}/\" /etc/rhn/rhn.conf || echo \"web.version = ${FULL_VERSION}\" >> /etc/rhn/rhn.conf"
{% endif %}

{% if grains.get('enable_oval_metadata') | default(false, true) %}
oval_metadata_services_restart:
  cmd.run:
    - name: mgrctl exec systemctl restart tomcat taskomatic
    - watch:
      - cmd: oval_metadata_enable_synchronization
  - require:
      - file: write_rhn_conf
{% endif %}

rhn_conf_present:
  cmd.run:
    - name: mgrctl exec 'touch /etc/rhn/rhn.conf'

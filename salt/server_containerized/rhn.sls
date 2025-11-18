{% if grains.get('skip_changelog_import') %}
package_import_skip_changelog_reposync:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "^package_import_skip_changelog.*$" /etc/rhn/rhn.conf &&
        sed -i "s/^package_import_skip_changelog.*/package_import_skip_changelog = 1/" /etc/rhn/rhn.conf ||
        echo "package_import_skip_changelog = 1" >> /etc/rhn/rhn.conf'
{% endif %}

limit_changelog_entries:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "java\.max_changelog_entries" /etc/rhn/rhn.conf &&
        sed -i "s/java\.max_changelog_entries.*/java.max_changelog_entries = 3/" /etc/rhn/rhn.conf ||
        echo "java.max_changelog_entries = 3" >> /etc/rhn/rhn.conf'

{% if grains.get('disable_download_tokens') %}
disable_download_tokens:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "^java\.salt_check_download_tokens.*$" /etc/rhn/rhn.conf &&
        sed -i "s/^java\.salt_check_download_tokens.*/java.salt_check_download_tokens = false/" /etc/rhn/rhn.conf ||
        echo "java.salt_check_download_tokens = false" >> /etc/rhn/rhn.conf'
{% endif %}

{% if grains.get('monitored') | default(false, true) %}
rhn_conf_prometheus:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "^prometheus_monitoring_enabled.*$" /etc/rhn/rhn.conf &&
        sed -i "s/^prometheus_monitoring_enabled.*/prometheus_monitoring_enabled = true/" /etc/rhn/rhn.conf ||
        echo "prometheus_monitoring_enabled = true" >> /etc/rhn/rhn.conf'
{% endif %}

{% if not grains.get('forward_registration') | default(false, true) %}
rhn_conf_forward_reg:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "^server\.susemanager\.forward_registration.*$" /etc/rhn/rhn.conf &&
        sed -i "s/^server\.susemanager\.forward_registration.*/server.susemanager.forward_registration = 0/" /etc/rhn/rhn.conf ||
        echo "server.susemanager.forward_registration = 0" >> /etc/rhn/rhn.conf'
{% endif %}

{% if grains.get('auto_bootstrap') == false | default(true, true) %}
rhn_conf_disable_auto_generate_bootstrap_repo:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "^server\.susemanager\.auto_generate_bootstrap_repo.*$" /etc/rhn/rhn.conf &&
        sed -i "s/^server\.susemanager\.auto_generate_bootstrap_repo.*/server.susemanager.auto_generate_bootstrap_repo = 0/" /etc/rhn/rhn.conf ||
        echo "server.susemanager.auto_generate_bootstrap_repo = 0" >> /etc/rhn/rhn.conf'
{% endif %}

{% if 'head' in grains.get('product_version') and grains.get('beta_enabled') %}
change_product_tree_to_beta:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "^java\.product_tree_tag.*$" /etc/rhn/rhn.conf &&
        sed -i "s/^java\.product_tree_tag.*/java.product_tree_tag = Beta/" /etc/rhn/rhn.conf ||
        echo "java.product_tree_tag = Beta" >> /etc/rhn/rhn.conf'
{% endif %}

{% if grains.get('testsuite') | default(false, true) %}
increase_presence_ping_timeout:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "^java\.salt_presence_ping_timeout\.*$" /etc/rhn/rhn.conf &&
        sed -i "s/^java\.salt_presence_ping_timeout.*/java.salt_presence_ping_timeout = 6/" /etc/rhn/rhn.conf ||
        echo "java.salt_presence_ping_timeout = 6" >> /etc/rhn/rhn.conf'
{% endif %}

# see https://documentation.suse.com/multi-linux-manager/5.1/en/docs/administration/auditing.html#_oval
{% if grains.get('enable_oval_metadata') | default(false, true) %}
oval_metadata_enable_synchronization:
  cmd.run:
    - name: |
        mgrctl exec 'grep -q "^java\.cve_audit\.enable_oval_metadata.*$" /etc/rhn/rhn.conf &&
        sed -i "s/^java\.cve_audit\.enable_oval_metadata.*/java.cve_audit.enable_oval_metadata = true/" /etc/rhn/rhn.conf ||
        echo "java.cve_audit.enable_oval_metadata = true" >> /etc/rhn/rhn.conf'

oval_metadata_services_restart:
  cmd.run:
    - name: mgrctl exec systemctl restart tomcat taskomatic
    - watch:
      - cmd: oval_metadata_enable_synchronization
{% endif %}

{% if 'nightly' in grains.get('product_version') %}
change_web_version:
  cmd.run:
    - name: |
        PRODUCT_VERSION=$(mgrctl exec "cat /etc/susemanager-release | awk -F'[()]' '{print \$2}'")
        BUILD_DATE=$(date +%Y%m%d)
        FULL_VERSION="${PRODUCT_VERSION}.${BUILD_DATE}"
        mgrctl exec "grep -q \"web.version\" /etc/rhn/rhn.conf &&
        sed -i \"s/web.version.*/web.version = ${FULL_VERSION}/\" /etc/rhn/rhn.conf ||
        echo \"web.version = ${FULL_VERSION}\" >> /etc/rhn/rhn.conf"
{% endif %}


rhn_conf_present:
  cmd.run:
    - name: mgrctl exec 'touch /etc/rhn/rhn.conf'

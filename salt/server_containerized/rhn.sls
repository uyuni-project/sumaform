{% if grains.get('skip_changelog_import') %}

package_import_skip_changelog_reposync:
  cmd.run:
    - name: mgrctl exec 'echo "package_import_skip_changelog = 1" >> /etc/rhn/rhn.conf'

{% endif %}

limit_changelog_entries:
  cmd.run:
    - name: mgrctl exec 'grep -q "java.max_changelog_entries" /etc/rhn/rhn.conf && sed -i "s/java.max_changelog_entries.*/java.max_changelog_entries = 3/" /etc/rhn/rhn.conf || echo "java.max_changelog_entries = 3" >> /etc/rhn/rhn.conf'

{% if grains.get('disable_download_tokens') %}
disable_download_tokens:
  cmd.run:
    - name: mgrctl exec 'echo "java.salt_check_download_tokens = false" >> /etc/rhn/rhn.conf'
{% endif %}

{% if grains.get('monitored') | default(false, true) %}

rhn_conf_prometheus:
  cmd.run:
    - name: mgrctl exec 'echo "prometheus_monitoring_enabled = true" >> /etc/rhn/rhn.conf'

{% endif %}

{% if not grains.get('forward_registration') | default(false, true) %}

rhn_conf_forward_reg:
  cmd.run:
    - name: mgrctl exec 'echo "server.susemanager.forward_registration = 0" >> /etc/rhn/rhn.conf'

{% endif %}

{% if grains.get('disable_auto_bootstrap') | default(false, true) %}

rhn_conf_disable_auto_generate_bootstrap_repo:
  cmd.run:
    - name: mgrctl exec 'echo "server.susemanager.auto_generate_bootstrap_repo = 0" >> /etc/rhn/rhn.conf'

{% endif %}

{% if 'head' in grains.get('product_version') and grains.get('beta_enabled') %}
change_product_tree_to_beta:
  cmd.run:
    - name: mgrctl exec 'grep -q "java.product_tree_tag" /etc/rhn/rhn.conf && sed -i "s/java.product_tree_tag = .*/java.product_tree_tag = Beta/" /etc/rhn/rhn.conf || echo "java.product_tree_tag = Beta" >> /etc/rhn/rhn.conf'
{% endif %}

{% if grains.get('testsuite') | default(false, true) %}
increase_presence_ping_timeout:
  cmd.run:
    - name: mgrctl exec 'echo "presence_ping_timeout = 6" >> /etc/rhn/rhn.conf'
{% endif %}

rhn_conf_present:
  cmd.run:
    - name: mgrctl exec 'touch /etc/rhn/rhn.conf'

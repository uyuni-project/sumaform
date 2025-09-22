# see https://documentation.suse.com/multi-linux-manager/5.1/en/docs/administration/auditing.html#_oval

{% if grains.get('enable_oval_metadata') | default(false, true) %}

oval_metadata_enable_synchronization:
  cmd.run:
    - name: mgrctl exec 'echo "java.cve_audit.enable_oval_metadata=true" >> /etc/rhn/rhn.conf'

oval_metadata_server_restart:
  cmd.run:
    - name: mgradm restart
    - watch:
      - cmd: oval_metadata_enable_synchronization

{% endif %}

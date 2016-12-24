include:
  - suse-manager.main

# Depending on repository configuration, Salt itself might need to be upgraded.
# This is done in a separate sls file so that the upgrade is the last applied
# state, as subsequent states might not be working correctly until the process
# is restarted

allow-vendor-changes:
  file.managed:
    - name: /etc/zypp/vendors.d/suse
    - makedirs: True
    - contents: |
        [main]
        vendors = SUSE,obs://build.suse.de/Devel:Galaxy:Manager

salt:
  pkg.latest:
    - require:
      - file: allow-vendor-changes
      - sls: suse-manager.main

# HACK: this is needed because after the upgrade salt-api need restart
# and restart.sls from salt don't work
salt-api:
  cmd.run:
   - name: service salt-api restart
   - require:
      - pkg: salt-api

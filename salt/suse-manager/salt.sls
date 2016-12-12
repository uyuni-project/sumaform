include:
  - suse-manager.main

# Depending on repository configuration, Salt itself might need to be upgraded.
# This is done in a separate sls file so that the upgrade is the last applied
# state, as subsequent states might not be working correctly until the process
# is restarted
salt:
  pkg.latest:
    - require:
      - sls: suse-manager.main

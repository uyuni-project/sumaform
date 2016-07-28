# Run with:
# sudo salt-call --local state.sls suse-manager.sles11sp3_osad_bootstrap_script

mgr-sync-auth:
  file.append:
    - name: /root/.mgr-sync
    - text: |
        mgrsync.user = admin
        mgrsync.password = admin

refresh-scc-data:
{% if '2.1' in grains['version'] %}
  cmd.run:
    - name: mgr-sync enable-scc
    - creates: /var/lib/spacewalk/scc/migrated
    - require:
      - file: mgr-sync-auth
{% else %}
  cmd.run:
    - name: mgr-sync refresh
    - require:
      - file: mgr-sync-auth
{% endif %}

sync-sles11sp3-channels:
  cmd.run:
    - name: mgr-sync add channel sles11-sp3-pool-x86_64 sles11-sp3-updates-x86_64 sles11-sp3-suse-manager-tools-x86_64
    - unless: mgr-sync list channel -c -f sles11-sp3-suse-manager-tools-x86_64 | grep "\[I\] sles11-sp3-suse-manager-tools-x86_64"
    - require:
      - cmd: refresh-scc-data

create-sles11sp3-activation-key:
  cmd.run:
    - name: |
{% if '2.1' in grains['version'] %}
        spacecmd -u admin -p admin -- activationkey_create -n sles11sp3-osad -d sles11sp3-osad -b sles11-sp3-pool-x86_64 -e provisioning_entitled &&
{% else %}
        spacecmd -u admin -p admin -- activationkey_create -n sles11sp3-osad -d sles11sp3-osad -b sles11-sp3-pool-x86_64 &&
{% endif %}
        spacecmd -u admin -p admin -- activationkey_addchildchannels 1-sles11sp3-osad sles11-sp3-updates-x86_64 sles11-sp3-suse-manager-tools-x86_64 &&
        spacecmd -u admin -p admin -- activationkey_addpackages 1-sles11sp3-osad osad rhncfg-actions
    - unless: spacecmd -u admin -p admin activationkey_list | grep -x 1-sles11sp3-osad
    - require:
      - cmd: sync-sles11sp3-channels

create-sles11sp3-bootstrap-script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-sles11sp3-osad --script=bootstrap-sles11sp3-osad.sh --allow-config-actions --no-up2date
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap-sles11sp3-osad.sh
    - require:
      - cmd: create-sles11sp3-activation-key

create-sles11sp3-bootstrap-script-md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap-sles11sp3-osad.sh > /srv/www/htdocs/pub/bootstrap/bootstrap-sles11sp3-osad.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap-sles11sp3-osad.sh.sha512
    - require:
      - cmd: create-sles11sp3-bootstrap-script

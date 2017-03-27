# Run with:
# sudo salt-call --local state.sls suse-manager.sles12_osad_bootstrap_script

mgr_sync_auth:
  file.append:
    - name: /root/.mgr-sync
    - text: |
        mgrsync.user = admin
        mgrsync.password = admin

scc_data_refresh:
{% if '2.1' in grains['version'] %}
  cmd.run:
    - name: mgr-sync enable-scc
    - creates: /var/lib/spacewalk/scc/migrated
    - require:
      - file: mgr_sync_auth
{% else %}
  cmd.run:
    - name: mgr-sync refresh
    - require:
      - file: mgr_sync_auth
{% endif %}

sync_sles12_channels:
  cmd.run:
    - name: mgr-sync add channel sles12-pool-x86_64 sles12-updates-x86_64 sle-manager-tools12-pool-x86_64 sle-manager-tools12-updates-x86_64
    - unless: mgr-sync list channel -c -f sle-manager-tools12-updates-x86_64 | grep "\[I\] sle-manager-tools12-updates-x86_64"
    - require:
      - cmd: scc_data_refresh

create_sles12_activation_key:
  cmd.run:
    - name: |
{% if '2.1' in grains['version'] %}
        spacecmd -u admin -p admin -- activationkey_create -n sles12-osad -d sles12-osad -b sles12-pool-x86_64 -e provisioning_entitled &&
{% else %}
        spacecmd -u admin -p admin -- activationkey_create -n sles12-osad -d sles12-osad -b sles12-pool-x86_64 &&
{% endif %}
        spacecmd -u admin -p admin -- activationkey_addchildchannels 1-sles12-osad sles12-updates-x86_64 sle-manager-tools12-pool-x86_64 sle-manager-tools12-updates-x86_64 &&
        spacecmd -u admin -p admin -- activationkey_addpackages 1-sles12-osad osad rhncfg-actions
    - unless: spacecmd -u admin -p admin activationkey_list | grep -x 1-sles12-osad
    - require:
      - cmd: sync_sles12_channels

create_sles12_bootstrap_script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-sles12-osad --script=bootstrap-sles12-osad.sh --allow-config-actions --no-up2date
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap-sles12-osad.sh
    - require:
      - cmd: create_sles12_activation_key

create_sles12_bootstrap_script_md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap-sles12-osad.sh > /srv/www/htdocs/pub/bootstrap/bootstrap-sles12-osad.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap-sles12-osad.sh.sha512
    - require:
      - cmd: create_sles12_bootstrap_script

{% if '2.1' in grains['version'] %}
create_sles12_bootstrap_repo:
  cmd.run:
    - name: mgr-create-bootstrap-repo --create=SLE-12-x86_64
    - creates: /srv/www/htdocs/pub/repositories/sle/12/0
    - require:
      - cmd: sync_sles12_channels
{% endif %}

# Run with:
# sudo salt-call --local state.sls suse-manager.sles12sp1_osad_bootstrap_script

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

sync-sles12sp1-channels:
  cmd.run:
    - name: mgr-sync add channel sles12-sp1-pool-x86_64 sles12-sp1-updates-x86_64 sle-manager-tools12-pool-x86_64-sp1 sle-manager-tools12-updates-x86_64-sp1
    - unless: mgr-sync list channel -c -f sle-manager-tools12-updates-x86_64-sp1 | grep "\[I\] sle-manager-tools12-updates-x86_64-sp1"
    - require:
      - cmd: refresh-scc-data

create-sles12-activation-key:
  cmd.run:
    - name: |
{% if '2.1' in grains['version'] %}
        spacecmd -u admin -p admin -- activationkey_create -n sles12sp1-osad -d sles12sp1-osad -b sles12-sp1-pool-x86_64 -e provisioning_entitled &&
{% else %}
        spacecmd -u admin -p admin -- activationkey_create -n sles12sp1-osad -d sles12sp1-osad -b sles12-sp1-pool-x86_64 &&
{% endif %}
        spacecmd -u admin -p admin -- activationkey_addchildchannels 1-sles12sp1-osad sles12-sp1-updates-x86_64 sle-manager-tools12-pool-x86_64-sp1 sle-manager-tools12-updates-x86_64-sp1 &&
        spacecmd -u admin -p admin -- activationkey_addpackages 1-sles12sp1-osad osad rhncfg-actions
    - unless: spacecmd -u admin -p admin activationkey_list | grep -x 1-sles12sp1-osad
    - require:
      - cmd: sync-sles12sp1-channels

create-sles12-bootstrap-script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-sles12sp1-osad --script=bootstrap-sles12sp1-osad.sh --allow-config-actions --no-up2date
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap-sles12sp1-osad.sh
    - require:
      - cmd: create-sles12-activation-key

create-sles12-bootstrap-script-md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap-sles12sp1-osad.sh > /srv/www/htdocs/pub/bootstrap/bootstrap-sles12sp1-osad.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap-sles12sp1-osad.sh.sha512
    - require:
      - cmd: create-sles12-bootstrap-script

{% if '2.1' in grains['version'] %}
create-sles12-bootstrap-repo:
  cmd.run:
    - name: mgr-create-bootstrap-repo --create=SLE-12-SP1-x86_64
    - creates: /srv/www/htdocs/pub/repositories/sle/12/1
    - require:
      - cmd: sync-sles12sp1-channels
{% endif %}

{% set container_runtime = grains.get('container_runtime') | default('podman', true) %}

include:
  - server_containerized.install_{{ container_runtime }}

{% set server_username = grains.get('server_username') | default('admin', true) %}
{% set server_password = grains.get('server_password') | default('admin', true) %}

{% if grains.get('create_first_user') %}
# set password in case user already existed with a different password
first_user_set_password:
  cmd.run:
    - name: mgrctl exec 'echo -e "{{ server_password }}\\n{{ server_password }}" | satpasswd -s {{ server_username }}'
    - require:
      - cmd: mgradm_install
{% endif %}

{% if grains.get('mgr_sync_autologin') %}
mgr_sync_automatic_authentication:
  cmd.run:
     - name: mgrctl exec 'echo -e "mgrsync.user = {{ server_username }}\\nmgrsync.password = {{ server_password }}\\n" > /root/.mgr-sync'

{% endif %}

wait_for_api_ready:
  cmd.run:
    - name: |
        until mgrctl exec "curl -s -k --fail http://localhost/rpc/api" >/dev/null 2>&1; do
          echo "Waiting for Uyuni API to initialize..."
          sleep 15
        done
    - timeout: 600
    - require:
      - cmd: mgradm_install

scc_data_refresh:
{% if grains.get('cc_username') %}
  cmd.script:
    - name: salt://server_containerized/wait_for_mgr_sync.sh
    - use_vt: True
    - args: "{{ server_username }} {{ server_password }}"
{% else %}
  test.nop:
    - name: "Skipping SCC sync, no credentials provided"
{% endif %}
    - require:
      - cmd: wait_for_api_ready

{% if grains.get('channels') %}
add_channels:
  cmd.run:
    - name: mgrctl exec mgr-sync add channels {{ ' '.join(grains['channels']) }}
    - require:
      - cmd: scc_data_refresh

{% if grains.get('wait_for_reposync') %}
{% for channel in grains.get('channels') %}
reposync_{{ channel }}:
  cmd.script:
    - name: salt://server/wait_for_reposync.py
    - template: jinja
    - args: "{{ server_username }} {{ server_password }} {{ grains.get('fqdn') | default('localhost', true) }} {{ channel }}"
    - use_vt: True
    - require:
      - cmd: add_channels
{% endfor %}
{% endif %}
{% endif %}

{% if grains.get('create_sample_channel') %}
create_empty_channel:
  cmd.run:
    - name: mgrctl exec "spacecmd -u {{ server_username }} -p {{ server_password }} -- softwarechannel_create --name testchannel -l testchannel -a x86_64"
    - unless: mgrctl exec "spacecmd -u {{ server_username }} -p {{ server_password }} softwarechannel_list | grep -x testchannel"
    - require:
      - cmd: mgradm_install
{% endif %}

{% if grains.get('create_sample_activation_key') %}
create_empty_activation_key:
  cmd.run:
    - name: mgrctl exec "spacecmd -u {{ server_username }} -p {{ server_password }} -- activationkey_create -n DEFAULT {{ '-b testchannel' if grains.get('create_sample_channel') else '' }}"
    - unless: mgrctl exec "spacecmd -u {{ server_username }} -p {{ server_password }} activationkey_list | grep -x 1-DEFAULT"
    - require:
      - cmd: create_empty_channel
{% endif %}

{% if grains.get('create_sample_bootstrap_script') %}
create_empty_bootstrap_script:
  cmd.run:
    - name: mgrctl exec "rhn-bootstrap --activation-keys=1-DEFAULT --hostname {{ grains['hostname'] }}.{{ grains['domain'] }}"
    - require:
      - cmd: create_empty_activation_key

create_empty_bootstrap_script_md5:
  cmd.run:
    - name: mgrctl exec "sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap.sh > /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512"
    - require:
      - cmd: create_empty_bootstrap_script
{% endif %}

{% if grains.get('container_runtime') == 'podman' and grains.get('publish_private_ssl_key') %}
private_ssl_key:
  cmd.run:
    - name: mgrctl exec "cp /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY; chmod 644 /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY"

private_ssl_key_checksum:
  cmd.run:
    - name: mgrctl exec "sha512sum /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY > /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512"
    - require:
      - cmd: private_ssl_key

ca_configuration:
  cmd.run:
    - name: mgrctl exec "cp /root/ssl-build/rhn-ca-openssl.cnf /srv/www/htdocs/pub/rhn-ca-openssl.cnf; chmod 644 /srv/www/htdocs/pub/rhn-ca-openssl.cnf"

ca_configuration_checksum:
  cmd.run:
    - name: mgrctl exec "sha512sum /srv/www/htdocs/pub/rhn-ca-openssl.cnf > /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512"
    - require:
      - cmd: ca_configuration
{% endif %}

{% if grains.get('cloned_channels') %}
spacewalk_utils:
  pkg.installed:
    - name: spacewalk-utils

{% for cloned_channel_set in grains.get('cloned_channels') %}
create_cloned_channels_{{ cloned_channel_set['prefix'] }}:
  cmd.run:
    - name: |
        spacewalk-clone-by-date \
          -u {{ grains.get('server_username') | default('admin', true) }} \
          -p {{ grains.get('server_password') | default('admin', true) }} \
          {%- for channel in cloned_channel_set['channels'] %}
          --channels={{ channel }} {{ cloned_channel_set['prefix'] }}-{{ channel }} \
          {%- endfor %}
          --to_date={{ cloned_channel_set['date'] }} \
          --assumeyes
    - unless: spacecmd -u {{ grains.get('server_username') | default('admin', true) }} -p {{ grains.get('server_password') | default('admin', true) }} softwarechannel_list | grep -x {{ cloned_channel_set['prefix'] }}-{{ cloned_channel_set['channels'] | first }}
    - require:
      - pkg: spacewalk_utils

create_{{ cloned_channel_set['prefix'] }}_activation_key:
  cmd.run:
    - name: |
        spacecmd \
          -u {{ grains.get('server_username') | default('admin', true) }} \
          -p {{ grains.get('server_password') | default('admin', true) }} \
          -- activationkey_create -n {{ cloned_channel_set['prefix'] }} -d {{ cloned_channel_set['prefix'] }} \
          -b {{ cloned_channel_set['prefix'] }}-{{ cloned_channel_set['channels'] | first }} &&
        spacecmd \
          -u {{ grains.get('server_username') | default('admin', true) }} \
          -p {{ grains.get('server_password') | default('admin', true) }} \
          -- activationkey_addchildchannels 1-{{ cloned_channel_set['prefix'] }} \
          {%- for channel in cloned_channel_set['channels'][1:] %}
          {{ cloned_channel_set['prefix'] }}-{{ channel }} \
          {%- endfor %}
    - unless: spacecmd -u admin -p admin activationkey_list | grep -x 1-{{ cloned_channel_set['prefix'] }}
    - require:
      - cmd: create_cloned_channels_{{ cloned_channel_set['prefix'] }}
{% endfor %}
{% endif %}

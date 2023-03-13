
{% set server_username = grains.get('server_username') | default('admin', true) %}
{% set server_password = grains.get('server_password') | default('admin', true) %}

{% if grains.get('create_first_user') %}

wait_for_tomcat:
  http.wait_for_successful_query:
    - method: GET
    - name: https://localhost/
    - verify_ssl: False
    - status: 200

create_first_user:
  http.wait_for_successful_query:
    - method: POST
    - name: https://localhost/rhn/newlogin/CreateFirstUser.do
    - status: 200
    - data: "submitted=true&\
             orgName=SUSE&\
             login={{ server_username }}&\
             desiredpassword={{ server_password }}&\
             desiredpasswordConfirm={{ server_password }}&\
             email=galaxy-noise%40suse.de&\
             firstNames=Administrator&\
             lastName=Administrator"
    - verify_ssl: False
    - unless: satwho | grep -x {{ server_username }}
    - require:
      - http: wait_for_tomcat

# set password in case user already existed with a different password
first_user_set_password:
  cmd.run:
    - name: echo -e "{{ server_password }}\n{{ server_password }}" | satpasswd -s {{ server_username }}
    - require:
      - http: create_first_user

{% endif %}

{% if grains.get('mgr_sync_autologin') %}

mgr_sync_configuration_file:
  file.managed:
    - name: /root/.mgr-sync
    - replace: false
    - require:
      - http: create_first_user

mgr_sync_automatic_authentication:
  file.replace:
    - name: /root/.mgr-sync
    - pattern: mgrsync.user =.*\nmgrsync.password =.*\n
    - repl: |
        mgrsync.user = {{ grains.get('server_username') | default('admin', true) }}
        mgrsync.password = {{ grains.get('server_password') | default('admin', true) }}
    - append_if_not_found: true
    - require:
      - file: mgr_sync_configuration_file

{% endif %}

{% if grains.get('channels') %}
wait_for_mgr_sync:
  cmd.script:
    - name: salt://server/wait_for_mgr_sync.py
    - use_vt: True
    - template: jinja
    - require:
      - http: create_first_user

scc_data_refresh:
  cmd.run:
    - name: mgr-sync refresh
    - use_vt: True
    - unless: spacecmd -u {{ grains.get('server_username') | default('admin', true) }} -p {{ grains.get('server_password') | default('admin', true) }} --quiet api sync.content.listProducts | grep name
    - require:
      - cmd: wait_for_mgr_sync
{% endif %}

{% if grains.get('channels') %}
add_channels:
  cmd.run:
    - name: mgr-sync add channels {{ ' '.join(grains['channels']) }}
    - require:
      - cmd: scc_data_refresh

{% if grains.get('wait_for_reposync') %}
{% for channel in grains.get('channels') %}
reposync_{{ channel }}:
  cmd.script:
    - name: salt://server/wait_for_reposync.py
    - template: jinja
    - args: "{{ grains.get('server_username') | default('admin', true) }} {{ grains.get('server_password') | default('admin', true) }} {{ grains.get('fqdn') | default('localhost', true) }} {{ channel }}"
    - use_vt: True
    - require:
      - cmd: add_channels
{% endfor %}
{% endif %}
{% endif %}

{% if grains.get('create_sample_channel') %}
create_empty_channel:
  cmd.run:
    - name: spacecmd -u {{ grains.get('server_username') | default('admin', true) }} -p {{ grains.get('server_password') | default('admin', true) }} -- softwarechannel_create --name testchannel -l testchannel -a x86_64
    - unless: spacecmd -u {{ grains.get('server_username') | default('admin', true) }} -p {{ grains.get('server_password') | default('admin', true) }} softwarechannel_list | grep -x testchannel
    - require:
      - http: create_first_user
{% endif %}

{% if grains.get('create_sample_activation_key') %}
create_empty_activation_key:
  cmd.run:
    - name: spacecmd -u {{ grains.get('server_username') | default('admin', true) }} -p {{ grains.get('server_password') | default('admin', true) }} -- activationkey_create -n DEFAULT {% if grains.get('create_sample_channel') %} -b testchannel {% endif %}
    - unless: spacecmd -u {{ grains.get('server_username') | default('admin', true) }} -p {{ grains.get('server_password') | default('admin', true) }} activationkey_list | grep -x 1-DEFAULT
    - require:
      - cmd: create_empty_channel
{% endif %}

{% if grains.get('create_sample_bootstrap_script') %}
create_empty_bootstrap_script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-DEFAULT --hostname {{ grains['hostname'] }}.{{ grains['domain'] }}
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh
    - require:
      - cmd: create_empty_activation_key

create_empty_bootstrap_script_md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap.sh > /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - require:
      - cmd: create_empty_bootstrap_script
{% endif %}

{% if grains.get('publish_private_ssl_key') %}
private_ssl_key:
  file.copy:
    - name: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY
    - source: /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY
    - mode: 644

private_ssl_key_checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY > /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - require:
      - file: private_ssl_key

ca_configuration:
  file.copy:
    - name: /srv/www/htdocs/pub/rhn-ca-openssl.cnf
    - source: /root/ssl-build/rhn-ca-openssl.cnf
    - mode: 644

ca_configuration_checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/rhn-ca-openssl.cnf > /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - creates: /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - require:
      - file: ca_configuration
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

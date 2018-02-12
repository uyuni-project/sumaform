include:
  - default

{% if '2.1' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-2.1-x86_64-Pool.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-2.1-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-2.1-x86_64-Update.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-2.1-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3.0' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3.1' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.1-x86_64-Pool.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-3.1-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.1-x86_64-Update.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-3.1-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if 'head' in grains['version'] %}
{% if grains['osfullname'] == 'Leap' %}
suse_manager_pool_repo:
  file.touch:
    - name: /tmp/no_pool_channel_needed

suse_manager_update_repo:
  file.touch:
    - name: /tmp/no_update_channel_needed

suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head_Leap.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_Head_Leap.repo
    - template: jinja
    - require:
      - sls: default
{% else %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_update_repo:
  file.touch:
    - name: /tmp/no_update_channel_needed

suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_Head.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}
{% endif %}

{% if '2.1-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_2.1.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_2.1.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3.0-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.0.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_3.0.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3.1-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.1.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_3.1.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if 'test' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - source: salt://suse_manager_server/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_update_repo:
  file.touch:
    - name: /tmp/no_update_channel_needed

suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_Head.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_test_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_TEST.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_TEST.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if 'oracle' in grains['database'] %}
suse_manager_oracle_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Oracle_SLE11.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Oracle_SLE11.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if 'pgpool' in grains['database'] %}
suse_manager_pgpool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/home_SilvioMoioli_pgpool.repo
    - source: salt://suse_manager_server/repos.d/home_SilvioMoioli_pgpool.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if grains['for_testsuite_only'] or grains.get('monitored') | default(false, true) %}
tools_repo:
  file.managed:
    - name: /etc/zypp/repos.d/home_SilvioMoioli_tools.repo
    - source: salt://suse_manager_server/repos.d/home_SilvioMoioli_tools.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if grains.get('log_server') | default(false, true) %}
filebeat_repo:
  file.managed:
    - name: /etc/zypp/repos.d/filebeat.repo
    - source: salt://suse_manager_server/repos.d/filebeat.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if grains['osmajorrelease']|int() == 11 %}
remove_client_tools_pool:
  file.absent:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-11-x86_64.repo
{% elif grains['osmajorrelease']|int() == 12 %}
remove_client_tools_pool:
  file.absent:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
{% elif grains['osmajorrelease']|int() == 15 %}
remove_client_tools_pool:
  file.absent:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-15-x86_64-Pool.repo
{% endif %}

{% if grains['osmajorrelease']|int() == 12 %}
remove_client_tools_update:
  file.absent:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
{% elif grains['osmajorrelease']|int() == 15 %}
remove_client_tools_update:
  file.absent:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-15-x86_64-Update.repo
{% endif %}

refresh_suse_manager_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: suse_manager_pool_repo
      - file: suse_manager_update_repo
      {% if ('nightly' in grains['version'] or 'head' in grains['version'] or 'test' in grains['version']) %}
      - file: suse_manager_devel_repo
      {% endif %}
      {% if 'test' in grains['version'] %}
      - file: suse_manager_test_repo
      {% endif %}
      {% if 'oracle' in grains['database'] %}
      - file: suse_manager_oracle_repo
      {% endif %}
      {% if 'pgpool' in grains['database'] %}
      - file: suse_manager_pgpool_repo
      {% endif %}
      {% if grains['for_testsuite_only'] or grains.get('monitored') | default(false, true) %}
      - file: tools_repo
      {% endif %}
      {% if grains.get('filebeat') | default(false, true) %}
      - file: filebeat_repo
      {% endif %}

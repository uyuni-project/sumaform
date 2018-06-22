
{% if '3.0' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - template: jinja

suse_manager_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if '3.1' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.1-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.1-x86_64-Pool.repo
    - template: jinja

suse_manager_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.1-x86_64-Update.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.1-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if '3.2' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.2-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.2-x86_64-Pool.repo
    - template: jinja

# HACK: the update repository for 3.2 does not exist yet
#       don't forget to add it after GA
suse_manager_update_repo:
  file.touch:
    - name: /tmp/no_update_channel_needed
{% endif %}

{% if 'head' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - template: jinja

suse_manager_update_repo:
  file.touch:
    - name: /tmp/no_update_channel_needed

suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_Head.repo
    - template: jinja
{% endif %}

{% if '3.0-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.0.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_3.0.repo
    - template: jinja
{% endif %}

{% if '3.1-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.1.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_3.1.repo
    - template: jinja
{% endif %}

{% if '3.2-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.2.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_3.2.repo
    - template: jinja
{% endif %}

{% if 'test' in grains['version'] %}
suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - template: jinja

suse_manager_update_repo:
  file.touch:
    - name: /tmp/no_update_channel_needed

suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_Head.repo
    - template: jinja

suse_manager_test_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_TEST.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_TEST.repo
    - template: jinja
{% endif %}

{% if grains.get('log_server') | default(false, true) %}
filebeat_repo:
  file.managed:
    - name: /etc/zypp/repos.d/filebeat.repo
    - source: salt://repos/repos.d/filebeat.repo
    - template: jinja
{% endif %}

{% if grains['osmajorrelease']|int() == 12 %}
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

{% if grains.get('monitored') | default(false, true) %}
prometheus_repo:
  file.managed:
    - name: /etc/zypp/repos.d/systemsmanagement-sumaform-tools.repo
    - source: salt://repos/repos.d/systemsmanagement-sumaform-tools.repo
    - template: jinja
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
      {% if grains.get('filebeat') | default(false, true) %}
      - file: filebeat_repo
      {% endif %}
      {% if grains.get('monitored') | default(false, true) %}
      - file: prometheus_repo
      {% endif %}

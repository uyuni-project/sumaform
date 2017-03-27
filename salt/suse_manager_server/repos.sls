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

{% if '3-' in grains['version'] %}
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
  file.touch:
    - name: /tmp/no_update_channel_needed
{% endif %}

{% if 'head' in grains['version'] %}
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

{% if '2.1-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_2.1.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_2.1.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.0.repo
    - source: salt://suse_manager_server/repos.d/Devel_Galaxy_Manager_3.0.repo
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

{% if grains['for_testsuite_only'] %}
lftp_repo:
  file.managed:
    - name: /etc/zypp/repos.d/home_SilvioMoioli_tools.repo
    - source: salt://suse_manager_server/repos.d/home_SilvioMoioli_tools.repo
    - require:
      - sls: default
{% endif %}

refresh_suse_manager_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: suse_manager_pool_repo
      - file: suse_manager_update_repo
      {% if ('nightly' in grains['version'] or 'head' in grains['version']) %}
      - file: suse_manager_devel_repo
      {% endif %}
      {% if 'oracle' in grains['database'] %}
      - file: suse_manager_oracle_repo
      {% endif %}
      {% if 'pgpool' in grains['database'] %}
      - file: suse_manager_pgpool_repo
      {% endif %}
      {% if grains['for_testsuite_only'] %}
      - file: lftp_repo
      {% endif %}

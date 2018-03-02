include:
  - default

{% if '2.1' in grains['version'] %}
suse_manager_proxy_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-2.1-x86_64-Pool.repo
    - source: salt://suse_manager_proxy/repos.d/SUSE-Manager-Proxy-2.1-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_proxy_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-2.1-x86_64-Update.repo
    - source: salt://suse_manager_proxy/repos.d/SUSE-Manager-Proxy-2.1-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3.0' in grains['version'] %}
suse_manager_proxy_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Pool.repo
    - source: salt://suse_manager_proxy/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_proxy_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Update.repo
    - source: salt://suse_manager_proxy/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3.1' in grains['version'] %}
suse_manager_proxy_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.1-x86_64-Pool.repo
    - source: salt://suse_manager_proxy/repos.d/SUSE-Manager-Proxy-3.1-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_proxy_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.1-x86_64-Update.repo
    - source: salt://suse_manager_proxy/repos.d/SUSE-Manager-Proxy-3.1-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if 'head' in grains['version'] %}
suse_manager_proxy_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-Head-x86_64-Pool.repo
    - source: salt://suse_manager_proxy/repos.d/SUSE-Manager-Proxy-Head-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse_manager_proxy_update_repo:
  file.touch:
    - name: /tmp/no_update_channel_needed

suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head.repo
    - source: salt://suse_manager_proxy/repos.d/Devel_Galaxy_Manager_Head.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '2.1-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_2.1.repo
    - source: salt://suse_manager_proxy/repos.d/Devel_Galaxy_Manager_2.1.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3.0-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.0.repo
    - source: salt://suse_manager_proxy/repos.d/Devel_Galaxy_Manager_3.0.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3.1-nightly' in grains['version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.1.repo
    - source: salt://suse_manager_proxy/repos.d/Devel_Galaxy_Manager_3.1.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

refresh_suse_manager_proxy_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: suse_manager_proxy_pool_repo
      - file: suse_manager_proxy_update_repo
      {% if ('nightly' in grains['version'] or 'head' in grains['version']) %}
      - file: suse_manager_devel_repo
      {% endif %}

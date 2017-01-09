include:
  - default

{% if '2.1' in grains['version'] %}
suse-manager-proxy-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-2.1-x86_64-Pool.repo
    - source: salt://suse-manager-proxy/repos.d/SUSE-Manager-Proxy-2.1-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse-manager-proxy-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-2.1-x86_64-Update.repo
    - source: salt://suse-manager-proxy/repos.d/SUSE-Manager-Proxy-2.1-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3' in grains['version'] %}
suse-manager-proxy-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Pool.repo
    - source: salt://suse-manager-proxy/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse-manager-proxy-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Update.repo
    - source: salt://suse-manager-proxy/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if 'head' in grains['version'] %}
suse-manager-proxy-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Pool.repo
    - source: salt://suse-manager-proxy/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Pool.repo
    - template: jinja
    - require:
      - sls: default

suse-manager-proxy-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Update.repo
    - source: salt://suse-manager-proxy/repos.d/SUSE-Manager-Proxy-3.0-x86_64-Update.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '2.1-nightly' in grains['version'] %}
suse-manager-devel-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_2.1.repo
    - source: salt://suse-manager-proxy/repos.d/Devel_Galaxy_Manager_2.1.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if '3-nightly' in grains['version'] %}
suse-manager-devel-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.0.repo
    - source: salt://suse-manager-proxy/repos.d/Devel_Galaxy_Manager_3.0.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

{% if 'head' in grains['version'] %}
suse-manager-devel-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head.repo
    - source: salt://suse-manager-proxy/repos.d/Devel_Galaxy_Manager_Head.repo
    - template: jinja
    - require:
      - sls: default
{% endif %}

refresh-suse-manager-proxy-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: suse-manager-proxy-pool-repo
      - file: suse-manager-proxy-update-repo
      {% if ('nightly' in grains['version'] or 'head' in grains['version']) %}
      - file: suse-manager-devel-repo
      {% endif %}

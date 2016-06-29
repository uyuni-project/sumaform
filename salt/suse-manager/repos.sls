include:
  - sles

# SUMa repos are a superset of sles repos, ensure they are present
sles-repos:
  test.nop:
    - require:
      - sls: sles

{% if '2.1' in grains['version'] %}
suma-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-2.1-x86_64-Pool.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-2.1-x86_64-Pool.repo
    - template: jinja

suma-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-2.1-x86_64-Update.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-2.1-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if '3' in grains['version'] %}
suma-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-3.0-x86_64-Pool.repo
    - template: jinja

suma-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if 'head' in grains['version'] %}
suma-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-Head-x86_64-Pool.repo
    - template: jinja

suma-devel-head-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head.repo
    - source: salt://suse-manager/repos.d/Devel_Galaxy_Manager_Head.repo
    - template: jinja
{% endif %}

{% if '2.1-nightly' in grains['version'] %}
suma-devel-2.1-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_2.1.repo
    - source: salt://suse-manager/repos.d/Devel_Galaxy_Manager_2.1.repo
    - template: jinja
{% endif %}

{% if '3-nightly' in grains['version'] %}
suma-devel-3.0-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.0.repo
    - source: salt://suse-manager/repos.d/Devel_Galaxy_Manager_3.0.repo
    - template: jinja
{% endif %}

{% if 'oracle' in grains['database'] %}
oracle-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Oracle_SLE11.repo
    - source: salt://suse-manager/repos.d/Devel_Galaxy_Oracle_SLE11.repo
    - template: jinja
{% endif %}

{% if 'pgpool' in grains['database'] %}
pgpool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/home_SilvioMoioli_pgpool.repo
    - source: salt://suse-manager/repos.d/home_SilvioMoioli_pgpool.repo
    - template: jinja
{% endif %}

{% if grains.get('role') == 'minionswarm' %}

suse_manager_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.2-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.2-x86_64-Pool.repo
    - template: jinja

suse_manager_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.2-x86_64-Update.repo
    - source: salt://repos/repos.d/SUSE-Manager-3.2-x86_64-Update.repo
    - template: jinja

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

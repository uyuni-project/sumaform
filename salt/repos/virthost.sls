{% if grains.get('virtual_host') | default(false, true) %}

{% if grains['osfullname'] == 'SLES' %}
{% if grains['osrelease'] == '15' %}
module_server_applications_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Module_Server_Applications_Pool.repo
    - source: salt://repos/repos.d/SLE-Module-Server-Applications-SLE-15-x86_64-Pool.repo
    - template: jinja

module_server_applications_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Module_Server_Applications_Update.repo
    - source: salt://repos/repos.d/SLE-Module-Server-Applications-SLE-15-x86_64-Update.repo
    - template: jinja
{% elif grains['osrelease'] == '15.1' %}
module_server_applications_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Module_Server_Applications_Pool.repo
    - source: salt://repos/repos.d/SLE-Module-Server-Applications-SLE-15-SP1-x86_64-Pool.repo
    - template: jinja

module_server_applications_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Module_Server_Applications_Update.repo
    - source: salt://repos/repos.d/SLE-Module-Server-Applications-SLE-15-SP1-x86_64-Update.repo
    - template: jinja
{% endif %}
{% endif %}

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

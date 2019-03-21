{% if grains.get('role') == 'virthost' %}

{% if grains['osfullname'] != 'Leap' and '15' in grains['osrelease']  %}
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

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

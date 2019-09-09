{% if grains.get('role') == 'suse_manager_proxy' %}

{% if '3.2' in grains['product_version'] %}
suse_manager_proxy_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.2-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-Proxy-3.2-x86_64-Pool.repo
    - template: jinja

suse_manager_proxy_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-3.2-x86_64-Update.repo
    - source: salt://repos/repos.d/SUSE-Manager-Proxy-3.2-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if '4.0' in grains['product_version'] %}
suse_manager_proxy_product_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Product-SUSE-Manager-Proxy-4.0-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-Product-SUSE-Manager-Proxy-4.0-x86_64-Pool.repo
    - template: jinja

suse_manager_proxy_product_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Product-SUSE-Manager-Proxy-4.0-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-Product-SUSE-Manager-Proxy-4.0-x86_64-Update.repo
    - template: jinja

suse_manager_proxy_module_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Module-SUSE-Manager-Proxy-4.0-x86_64-Pool.repo
    - source: salt://repos/repos.d/SLE-Module-SUSE-Manager-Proxy-4.0-x86_64-Pool.repo
    - template: jinja

suse_manager_proxy_module_update_repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Module-SUSE-Manager-Proxy-4.0-x86_64-Update.repo
    - source: salt://repos/repos.d/SLE-Module-SUSE-Manager-Proxy-4.0-x86_64-Update.repo
    - template: jinja

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

{% if 'uyuni-released' in grains['product_version'] %}
suse_manager_proxy_pool_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Uyuni-Proxy-Stable-x86_64-Pool.repo
    - source: salt://repos/repos.d/Uyuni-Proxy-Stable-x86_64-Pool.repo
    - template: jinja
{% endif %}

{% if 'head' in grains.get('product_version') or 'uyuni-master' in grains.get('product_version') %}
suse_manager_proxy_pool_repo:
  file.managed:
    {% if grains['osfullname'] == 'Leap' %}
    - name: /etc/zypp/repos.d/Uyuni-Proxy-Master-x86_64-Pool.repo
    - source: salt://repos/repos.d/Uyuni-Proxy-Master-x86_64-Pool.repo
    {% else %}
    - name: /etc/zypp/repos.d/SUSE-Manager-Proxy-Head-x86_64-Pool.repo
    - source: salt://repos/repos.d/SUSE-Manager-Proxy-Head-x86_64-Pool.repo
    {% endif %}
    - template: jinja

{% if grains['osfullname'] != 'Leap' %}
suse_manager_devel_releasenotes_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head_ToSLE.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_Head_ToSLE.repo
    - template: jinja
{% endif %}

suse_manager_devel_repo:
  file.managed:
    {% if grains['osfullname'] == 'Leap' %}
    - name: /etc/zypp/repos.d/systemsmanagement-Uyuni-Master-x86_64.repo
    - source: salt://repos/repos.d/systemsmanagement-Uyuni-Master-x86_64.repo
    {% else %}
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_Head.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_Head.repo
    {% endif %}
    - template: jinja

{% if grains['osfullname'] != 'Leap' %}
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

{% if '3.2-nightly' in grains['product_version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_3.2.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_3.2.repo
    - template: jinja
{% endif %}

{% if '4.0-nightly' in grains['product_version'] %}
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_4.0.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_4.0.repo
    - template: jinja

suse_manager_devel_releasenotes_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_Manager_4.0_ToSLE.repo
    - source: salt://repos/repos.d/Devel_Galaxy_Manager_4.0_ToSLE.repo
    - template: jinja
{% endif %}

{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

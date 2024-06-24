{% if 'proxy' in grains.get('roles') and not 'proxy_containerized' in grains.get('roles') and grains.get('proxy_registration_code') %}

{% if '4.2' in grains['product_version'] %}
register_suse_manager_proxy_with_scc:
   cmd.run:
     - name: SUSEConnect --url https://scc.suse.com -r {{ grains.get("proxy_registration_code") }} -p SUSE-Manager-Proxy/4.2/x86_64
add_sle_module_basesystem:
   cmd.run:
     - name: SUSEConnect -p sle-module-basesystem/15.3/x86_64
add_sle_module_server_application:
   cmd.run:
     - name: SUSEConnect -p sle-module-server-applications/15.3/x86_64
add_sle_module_suse_manager_proxy:
   cmd.run:
     - name: SUSEConnect -p sle-module-suse-manager-proxy/4.2/x86_64
{% endif %}

{% if '4.3' in grains['product_version'] %}
register_suse_manager_proxy_with_scc:
   cmd.run:
     - name: SUSEConnect --url https://scc.suse.com -r {{ grains.get("proxy_registration_code") }} -p SUSE-Manager-Proxy/4.3/x86_64
add_sle_module_basesystem:
   cmd.run:
     - name: SUSEConnect -p sle-module-basesystem/15.4/x86_64
add_sle_module_server_application:
   cmd.run:
     - name: SUSEConnect -p sle-module-server-applications/15.4/x86_64
add_sle_module_suse_manager_proxy:
   cmd.run:
     - name: SUSEConnect -p sle-module-suse-manager-proxy/4.3/x86_64
add_sle_module_suse_container:
   cmd.run:
     - name: SUSEConnect -p sle-module-containers/15.4/x86_64
{% endif %}

{% endif %}

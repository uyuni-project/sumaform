{% if 'build_host' in grains.get('roles') and grains.get('sles_registration_code') %}

register_sles_server:
   cmd.run:
     - name: SUSEConnect --url https://scc.suse.com -r {{ grains.get("sles_registration_code") }} -p SLES/{{ grains['osrelease'] }}/{{ grains.get("cpuarch") }}

basesystem_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-basesystem/{{ grains['osrelease'] }}/{{ grains.get("cpuarch") }}

containers_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-containers/{{ grains['osrelease'] }}/{{ grains.get("cpuarch") }}

desktop_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-desktop-applications/{{ grains['osrelease'] }}/{{ grains.get("cpuarch") }}

devel_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-development-tools/{{ grains['osrelease'] }}/{{ grains.get("cpuarch") }}

{% endif %}

{% if 'minion' in grains.get('roles') and grains.get('sles_registration_code') and '15' in grains['osrelease'] %}

cmd.run:
 - name: rpm -e --nodeps sles-release

activate_sles_server
   cmd.run:
     - name: SUSEConnect --url https://scc.suse.com -r {{ grains.get("sles_registration_code") }} -p sle-module-basesystem/{{ grains['osrelease'] }}/x86_64

containers_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-server-applications/{{ grains['osrelease'] }}/x86_64

desktop_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-desktop-applications/{{ grains['osrelease'] }}/x86_64

devel_activation:
   cmd.run:
     - name: SUSEConnect -p sle-module-development-tools/{{ grains['osrelease'] }}/x86_64

{% endif %}

{% if grains.get('apparmor') and grains['os'] == 'SUSE' %}

apparmor_packages:
  pkg.installed:
    - pkgs:
      - apparmor-parser
      - apparmor-profiles
      - apparmor-utils
      - audit

auditd:
  service.running:
    - enable: True
    - running: True
    - require:
      - pkg: apparmor_packages


# /usr/bin/salt-minion (python script) started by salt-minion service

apparmor_saltminion_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.bin.salt-minion
    - source: salt://minion/apparmor.d/usr.bin.salt-minion

apparmor_saltminion_complain_mode:
  cmd.run:
    - name: aa-complain /usr/bin/salt-minion
    - require:
      - service: auditd
      - file: apparmor_saltminion_profile

{% endif %}

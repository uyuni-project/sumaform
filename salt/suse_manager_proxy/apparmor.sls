{% if grains.get('apparmor') and grains['os'] == 'SUSE' %}

apparmor_packages:
  pkg.installed:
    - pkgs:
      - apparmor-parser
      - apparmor-profiles
      - apparmor-utils
      - audit
    - require:
      - pkg: proxy-packages

auditd:
  service.running:
    - enable: True
    - running: True
    - require:
      - pkg: apparmor_packages


# /usr/bin/salt-broker (python script) started by salt-broker service

apparmor_saltbroker_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.bin.salt-broker
    - source: salt://suse_manager_proxy/apparmor.d/usr.bin.salt-broker

apparmor_saltbroker_complain_mode:
  cmd.run:
    - name: aa-complain /usr/bin/salt-broker
    - require:
      - service: auditd
      - file: apparmor_saltbroker_profile


# /usr/sbin/squid started by squid service

apparmor_squid_profile:
  file.managed:
    - name: /etc/apparmor.d/usr.sbin.squid
    - source: salt://suse_manager_proxy/apparmor.d/usr.sbin.squid

apparmor_squid_complain_mode:
  cmd.run:
    - name: aa-complain /usr/sbin/squid
    - require:
      - service: auditd
      - file: apparmor_squid_profile

{% endif %}

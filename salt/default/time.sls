timezone_package:
  pkg.installed:
{% if grains['os_family'] == 'Suse' %}
    - name: timezone
{% else %}
    - name: tzdata
{% endif %}

timezone_symlink:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/{{ grains['timezone'] }}
    - force: true
    - require:
      - pkg: timezone_package

timezone_setting:
  timezone.system:
    - name: {{ grains['timezone'] }}
    - utc: True
    - require:
      - file: timezone_symlink

{% if grains['use_ntp'] %}

{% if grains['osfullname'] == 'SLES' %}

chrony_pkg:
  pkg.installed:
    - name: chrony

chrony_enable_service:
  service.running:
    - name: chronyd
    - enable: true

{% elif grains['osfullname'] == 'Leap' %}

ntp_pkg:
  pkg.installed:
    - name: ntp

ntp_conf_file:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://default/ntp.conf

ntp_enable_service:
  service.running:
    - name: ntpd
    - enable: true

{% endif %}

{% endif %}

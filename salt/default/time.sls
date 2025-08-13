{% if not grains.get('transactional', False) %}
# Dependencies already satisfied by the images
# https://build.opensuse.org/project/show/systemsmanagement:sumaform:images:microos
timezone_package:
  pkg.installed:
{% if grains['os_family'] == 'Suse' %}
    - name: timezone
{% else %}
    - name: tzdata
{% endif %}
{% endif %}

timezone_symlink:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/{{ grains['timezone'] }}
    - force: true
{% if not grains.get('transactional', False) %}
    - require:
      - pkg: timezone_package
{% endif %}

timezone_setting:
  timezone.system:
    - name: {{ grains['timezone'] }}
    - utc: True
    - require:
      - file: timezone_symlink

{% if grains['use_ntp'] %}

{% if  grains['osfullname'] == 'Leap' %}

ntp_pkg:
  pkg.installed:
    - name: ntp

ntp_conf_file:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://default/ntp.conf

ntpd_enable_service:
  service.running:
    - name: ntpd
    - enable: true

{% else %}

{% if not grains.get('transactional', False) %}
# Dependencies already satisfied by SLE Micro itself
chrony_pkg:
  pkg.installed:
    - name: chrony
{% endif %}

chrony_conf_file:
  file.managed:
    - name: /etc/chrony.conf
    - source: salt://default/chrony.conf

chrony_enable_service:
  service.running:
    - name: chronyd
    - enable: true

{% endif %}
{% endif %}

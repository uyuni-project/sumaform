{# This state setup special settings which are needed for various OSes #}

{% for keypath in grains.get('gpg_keys') | default([], true) %}
{% set keyname =  salt['file.basename'](keypath)  %}
gpg_key_copy_{{ keypath }}:
  file.managed:
    - name: /tmp/{{ keyname }}
    - source: salt://{{ keypath }}
install_{{ keypath }}:
  cmd.wait:
    - name: rpm --import /tmp/{{ salt['file.basename'](keypath) }}
    - watch:
      - file: /tmp/{{ keyname }}
{% endfor %}


{% if grains['os'] == 'SUSE' %}

{% if grains['osrelease_info'][0] == 15 and grains['osrelease_info'][1] >= 3 %}
# Needed because in sles15SP3 and opensuse 15.3 and higher firewalld will replace this package.
# But the tools_update_repo priority don't allow to cope with the Obsoletes option from firewalld
lock_firewalld_prometheus_config_leap_cmd:
   cmd.run:
     - name: zypper addlock firewalld-prometheus-config
{% endif %}

install_recommends:
  file.comment:
    - name: /etc/zypp/zypp.conf
    - regex: ^solver.onlyRequires =.*
{%- if grains['saltversioninfo'][0] >= 3005 %}
    - ignore_missing: True
{% endif %}
    - onlyif: grep ^solver.onlyRequires /etc/zypp/zypp.conf

{% endif %} {# grains['os'] == 'SUSE' #}


{% if grains['os_family'] == 'RedHat' %}

{% set release = grains.get('osmajorrelease', None)|int() %}

{% if release < 10 %}
{# Soon this key will be used for all non-suse repos. When it happens, replace galaxy_key with this #}
suse_el9_key:
  file.managed:
    - name: /tmp/suse_el9.key
    - source: salt://default/gpg_keys/suse_el9.key
  cmd.wait:
    - name: rpm --import /tmp/suse_el9.key
    - watch:
      - file: suse_el9_key

galaxy_key:
  file.managed:
    - name: /tmp/galaxy.key
    - source: salt://default/gpg_keys/galaxy.key
  cmd.wait:
    - name: rpm --import /tmp/galaxy.key
    - watch:
      - file: galaxy_key

suse_res7_key:
  file.managed:
    - name: /tmp/suse_res7.key
    - source: salt://default/gpg_keys/suse_res7.key
  cmd.wait:
    - name: rpm --import /tmp/suse_res7.key
    - watch:
      - file: suse_res7_key
{% endif %}

{% if 'uyuni-master' in grains.get('product_version', '') or 'uyuni-released' in grains.get('product_version', '') or 'uyuni-pr' in grains.get('product_version', '') %}

uyuni_key:
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key

{% endif %}
{% endif %} {# grains['os_family'] == 'RedHat' #}


{% if grains['os_family'] == 'Debian' %}

disable_apt_daily_timer:
  service.dead:
    - name: apt-daily.timer
    - enable: False

disable_apt_daily_upgrade_timer:
  service.dead:
    - name: apt-daily-upgrade.timer
    - enable: False

disable_apt_daily_service:
  service.dead:
    - name: apt-daily.service
    - enable: False

disable_apt_daily_upgrade_service:
  service.dead:
    - name: apt-daily-upgrade.service
    - enable: False

wait_until_apt_lock_file_unlock:
  cmd.run:
    - name: "test ! -f /var/lib/apt/lists/lock || ! lsof /var/lib/apt/lists/lock"
    - retry:
      - attempts: 10
      - interval: 5
      - until: True

remove_no_install_recommends:
  file.absent:
    - name: /etc/apt/apt.conf.d/00InstallRecommends

{% endif %} {# grains['os_family'] == 'Debian' #}

{# WORKAROUND: see github:saltstack/salt#10852 #}
{{ sls }}_nop:
  test.nop: []

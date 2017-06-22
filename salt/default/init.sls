include:
  - default.repos
  - default.pkgs
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  {% if grains['use_avahi'] %}
  - default.avahi
  {% endif %}
  {% if grains['reset_ids'] %}
  - default.ids
  {% endif %}

minimal_package_update:
  pkg.latest:
    - pkgs:
      - salt
      - salt-minion
{% if grains['os_family'] == 'Suse' %}
      - zypper
      - libzypp
{% endif %}
    - order: last
    - require:
      - sls: default.repos

timezone_setting:
  timezone.system:
    - name: {{ grains['timezone'] }}
    - utc: True

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

{% if grains.get('use_unreleased_updates', False) %}
update_sles_test:
  pkg.uptodate
{% endif %}

authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text: {{ salt["grains.get"]("authorized_keys") }}
    - makedirs: True

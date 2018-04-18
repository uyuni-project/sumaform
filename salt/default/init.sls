include:
  - default.minimal
  - default.repos
  - default.pkgs
  {% if grains.get('reset_ids') | default(false, true) %}
  - default.ids
  {% endif %}

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

{% if grains.get('use_unreleased_updates') | default(False, true) or grains.get('use_released_updates') | default(False, true) %}
update_packages:
  pkg.uptodate:
    - require:
      - sls: default.repos
{% endif %}

{% if grains['authorized_keys'] %}
authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text:
{% for key in grains['authorized_keys'] %}
      - {{ key }}
{% endfor %}
    - makedirs: True
{% endif %}

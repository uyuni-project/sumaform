include:
  - default.repos
  - default.pkgs

up-to-date-salt:
  pkg.latest:
    - name: salt
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

authorized-keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text: {{ salt["grains.get"]("authorized-keys") }}
    - makedirs: True

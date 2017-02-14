{% from "timezone/map.jinja" import confmap with context %}

timezone_setting:
  timezone.system:
    - name: {{ grains['timezone'] }}
    - utc: True

timezone_packages:
  pkg.installed:
    - name: {{ confmap.pkgname }}

timezone_symlink:
  file.symlink:
    - name: {{ confmap.path_localtime }}
    - target: {{ confmap.path_zoneinfo }}{{ grains['timezone'] }}
    - force: true
    - require:
      - pkg: {{ confmap.pkgname }}


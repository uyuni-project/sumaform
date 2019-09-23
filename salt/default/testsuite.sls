{% if grains.get('testsuite') | default(false, true) %}
{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'minionssh' in grains.get('roles') %}

include:
  - repos

{% if grains['os'] == 'SUSE' %}

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - sls: repos

{% elif grains['os_family'] == 'RedHat' %}

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - pkgrepo: test_repo_rpm_pool

{% endif %}
{% endif %}
{% endif %}

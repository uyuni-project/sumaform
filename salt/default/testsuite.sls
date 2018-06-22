{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('role') in ['client', 'minion', None] %}

include:
  - repos.testsuite

{% if grains['os'] == 'SUSE' %}

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - cmd: refresh_cucumber_repos

{% elif grains['os_family'] == 'RedHat' %}

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
    - require:
      - file: testsuite_build_repo

{% endif %}
{% endif %}
{% endif %}

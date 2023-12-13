{% if grains.get('testsuite') | default(false, true) %}
{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'sshminion' in grains.get('roles') %}

include:
  - scc
  - repos.testsuite

{% if grains['os'] == 'SUSE' %}

default_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
      - iptables
    - require:
      - sls: repos.testsuite

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

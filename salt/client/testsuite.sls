{% if grains.get('testsuite') | default(false, true) %}

include:
  - scc.minion
  - repos
  - client

client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - spacewalk-client-setup
      - spacewalk-check
      - mgr-cfg-actions
      - wget
    - require:
      - sls: default

{% if grains['os'] == 'SUSE' and '12' in grains['osrelease'] %}

suse_client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - aaa_base-extras
    - require:
      - sls: repos

{% endif %}

{% endif %}

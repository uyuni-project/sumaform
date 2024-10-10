{% if grains.get('testsuite') | default(false, true) %}

include:
  - repos
  - client

client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - spacewalk-client-setup
      - spacewalk-check
      - mgr-cfg-actions
# Debian based systems don't come with curl installed, the test suite handles it with wget instead
{% if grains['os_family'] == 'Debian' %}
      - wget
{% endif %}
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

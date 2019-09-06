{% if grains.get('testsuite') | default(false, true) %}

include:
  - repos
  - client

client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - spacewalk-client-setup
      - spacewalk-check
      - spacewalk-oscap
      - openscap-utils
      - mgr-cfg-actions
      {% if grains['os'] == 'CentOS' %}
      - man-db
      {% else %}
      - man
      {% endif %}
      - wget
    - require:
      - sls: default

{% if grains['os'] == 'SUSE' %}

suse_client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - openscap-content
      {% if '12' in grains['osrelease'] %}
      - aaa_base-extras
      {% endif %}
    - require:
      - sls: repos

{% endif %}

{% endif %}

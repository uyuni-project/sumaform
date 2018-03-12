{% if grains['for_testsuite_only'] %}

include:
  - client.repos

cucumber_requisites:
  pkg.installed:
    - pkgs:
      - subscription-tools
      - spacewalk-client-setup
      - spacewalk-check
      - spacewalk-oscap
      - rhncfg-actions
      - openscap-utils
      - man
      - wget
      {% if grains['os'] == 'SUSE' %}
      - openscap-content
      - andromeda-dummy
      - milkyway-dummy
      - virgo-dummy
      {% if '12' in grains['osrelease'] %}
      - aaa_base-extras
      {% endif %}
      {% endif %}
    - require:
      - sls: client.repos

{% if grains['os_family'] == 'Suse' %}
enforce_latest_libzypp:
  pkg.latest:
    - name: libzypp
    - require:
      - sls: client.repos
{% endif %}
{% endif %}

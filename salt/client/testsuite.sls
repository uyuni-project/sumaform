{% if grains.get('testsuite') | default(false, true) %}

include:
  - client

client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - spacewalk-client-setup
      - spacewalk-check
      - spacewalk-oscap
      - rhncfg-actions
      - openscap-utils
      - man
      - wget
    - require:
      - sls: default

{% if grains['os'] == 'SUSE' %}

refresh_client_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh

suse_client_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - openscap-content
      {% if '12' in grains['osrelease'] %}
      - aaa_base-extras
      {% endif %}
    - require:
      - cmd: refresh_client_repos

{% endif %}

{% endif %}

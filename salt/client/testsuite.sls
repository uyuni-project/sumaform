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

# HACK: Isssue #834 - SLES12SP4 python-cryptography rpm is pre-installed in our official image,
#                     but the version is too old for our bootstrap script, so we manually update it.
python-cryptography:
  pkg.latest:
    - fromrepo: os_update_repo
    - require:
      - sls: repos

{% endif %}

{% endif %}

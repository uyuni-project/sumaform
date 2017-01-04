include:
  - default

{% if grains['os'] == 'SUSE' and grains['for-testsuite-only'] %}

testsuite-build-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://client/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

# HACK: this repo should be removed, but we need this packages not otherwise available:
# "openscap-content", "openscap-extra-probes", "openscap-utils"
testsuite-suse-manager-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - template: jinja

refresh-client-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: default
      - file: testsuite-build-repo
      - file: testsuite-suse-manager-repo

{% else %}

no-client-repos:
  test.nop: []

{% endif %}

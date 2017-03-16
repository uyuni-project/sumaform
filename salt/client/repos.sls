include:
  - default

{% if grains['os'] == 'SUSE' and grains['for-testsuite-only'] %}

testsuite-build-repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://client/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja
    - require:
      - sls: default

refresh-client-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: testsuite-build-repo

{% else %}

no-client-repos:
  test.nop: []

{% endif %}

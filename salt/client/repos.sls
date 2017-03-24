include:
  - default

{% if grains['os'] == 'SUSE' and grains['for_testsuite_only'] %}

testsuite_build_repo:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://client/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja
    - require:
      - sls: default

refresh_client_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: testsuite_build_repo

{% else %}

no-client-repos:
  test.nop: []

{% endif %}

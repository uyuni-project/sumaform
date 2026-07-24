{% if grains['os'] == 'SUSE' and ('controller' in grains.get('roles')) %}
{% set repo_version = grains['osrelease'] %}

ruby_add_devel_repository:
    pkgrepo.managed:
      - name: ruby_devel
      - baseurl: "http://download.opensuse.org/repositories/devel:/languages:/ruby/{{ repo_version }}/"
      - refresh: True
      - gpgautoimport: True


{% if repo_version != '16.0' %}
ruby_gems_add_devel_repository:
    pkgrepo.managed:
      - name: ruby_devel_extensions
      - baseurl: "http://download.opensuse.org/repositories/devel:/languages:/ruby:/extensions/{{ repo_version }}/"
      - refresh: True
      - gpgautoimport: True
{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

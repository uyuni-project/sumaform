{% if grains['os'] == 'SUSE' and ('controller' in grains.get('roles')) %}

ruby_add_devel_repository:
    pkgrepo.managed:
      - name: Ruby devel
      - baseurl: http://download.opensuse.org/repositories/devel:/languages:/ruby/15.4/
      - refresh: True
      - gpgautoimport: True

ruby_gems_add_devel_repository:
    pkgrepo.managed:
      - name: Ruby devel extensions
      - baseurl: http://download.opensuse.org/repositories/devel:/languages:/ruby:/extensions/15.4/
      - refresh: True
      - gpgautoimport: True

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

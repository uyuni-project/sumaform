{% if grains['os'] == 'SUSE' and ('controller' in grains.get('roles')) %}

ruby_add_devel_repository:
    pkgrepo.managed:
      - name: ruby_devel
      - baseurl: http://download.opensuse.org/repositories/devel:/languages:/ruby/{{ grains['osrelease'] }}/
      - refresh: True
      - gpgautoimport: True

{# The ruby extensions devel repo has no Leap 16+ build; only add it on Leap 15.x #}
{% if grains['osrelease_info'][0] < 16 %}
ruby_gems_add_devel_repository:
    pkgrepo.managed:
      - name: ruby_devel_extensions
      - baseurl: http://download.opensuse.org/repositories/devel:/languages:/ruby:/extensions/{{ grains['osrelease'] }}/
      - refresh: True
      - gpgautoimport: True
{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

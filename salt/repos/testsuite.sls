{% if grains.get('testsuite') | default(false, true) %}
{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'minionssh' in grains.get('roles') %}

{% if (grains['os'] == 'SUSE') or (grains['os_family'] == 'RedHat') %}

test_repo_rpm_pool:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/standard_rpm/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/standard_rpm/repodata/repomd.xml.key

{% elif grains['os_family'] == 'Debian' %}

test_repo_deb_pool:
  pkgrepo.managed:
    - name: deb http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/standard_deb/ /
    - file: /etc/apt/sources.list.d/Test-Packages_Pool.list
    - key_url: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/standard_deb/Release.key

{% endif %}
{% endif %}
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

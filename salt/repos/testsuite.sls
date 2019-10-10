{% if grains.get('testsuite') | default(false, true) %}
{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'minionssh' in grains.get('roles') %}

{% if (grains['os'] == 'SUSE') or (grains['os_family'] == 'RedHat') %}

uyuni_key_for_fake_packages:
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key_for_fake_packages

test_repo_rpm_pool:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/rpm/
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/rpm/repodata/repomd.xml.key

{% elif grains['os_family'] == 'Debian' %}

test_repo_deb_pool:
  pkgrepo.managed:
    - name: deb http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/deb/ /
    - file: /etc/apt/sources.list.d/Test-Packages_Pool.list
    - key_url: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/deb/Release.key

{% endif %}
{% endif %}
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

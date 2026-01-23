{% if grains.get('testsuite') | default(false, true) %}
{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'sshminion' in grains.get('roles') %}

{% if (grains['os'] == 'SUSE') or (grains['os_family'] == 'RedHat') %}

uyuni_key_for_fake_packages:
{% if not grains['osfullname'] in ['SLE Micro', 'SL-Micro'] %}
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key_for_fake_packages
{% else %}
  cmd.run:
    - name: transactional-update -c run rpm --import http://{{ grains.get("mirror") | default("minima-mirror-ci-bv.mgr.slc1.suse.org", true) }}/uyuni.key
{% endif %}

{% if not (grains['osfullname'] in ['SLE-Micro', 'SL-Micro', 'openSUSE Leap Micro']) %}
test_repo_rpm_pool:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/rpm/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/rpm/repodata/repomd.xml.key
    - keys:
        - http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/rpm/repodata/repomd.xml.key

{% if (grains['osfinger'] == "SLES-12") %}
refresh_test_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh --force; exit 0
{% endif %}

{% endif %} {# already added via combustion #}

{% elif grains['os_family'] == 'Debian' %}

test_repo_deb_pool:
  pkgrepo.managed:
    - name: deb http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/deb/ /
    - refresh: True
    - file: /etc/apt/sources.list.d/test_repo_deb_pool.list
    - key_url: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Pool/deb/Release.key

{% endif %}
{% endif %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

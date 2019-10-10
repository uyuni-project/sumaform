{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('role') in ['client', 'minion', 'minionssh'] %}

{% if grains['os'] == 'SUSE' %}

uyuni_key_for_fake_packages:
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key_for_fake_packages

test_repo_rpm_pool:
  file.managed:
    - name: /etc/zypp/repos.d/Test-Packages_Pool.repo
    - source: salt://repos/repos.d/Test-Packages_Pool.repo
    - template: jinja

{% elif grains['os_family'] == 'RedHat' %}

uyuni_key_for_fake_packages:
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key_for_fake_packages

test_repo_rpm_pool:
  file.managed:
    - name: /etc/yum.repos.d/Test-Packages_Pool.repo
    - source: salt://repos/repos.d/Test-Packages_Pool.repo
    - template: jinja

{% elif grains['os_family'] == 'Debian' %}

test_repo_deb_pool:
  file.managed:
    - name: /etc/apt/sources.list.d/Test-Packages_Pool.list
    - source: salt://repos/repos.d/Test-Packages_Pool.list
    - template: jinja

{% endif %}
{% endif %}
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

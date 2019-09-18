{% if grains.get('testsuite') | default(false, true) %}
{% if grains.get('role') in ['client', 'minion', None] %}

{% if grains['os'] == 'SUSE' %}

testsuite_build_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/BuildRepo/SLE_12_SP4/

{% elif grains['os_family'] == 'RedHat' %}

testsuite_build_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/BuildRepo/SLE_12_SP4/

{% elif grains['os_family'] == 'Debian' %}

testsuite_build_repo:
  pkgrepo.managed:
    - name: deb [trusted=yes] https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Ubuntu-Test/xUbuntu_18.04 /
    - file: /etc/apt/sources.list.d/Devel_Uyuni_BuildRepo.list

{% endif %}
{% endif %}
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

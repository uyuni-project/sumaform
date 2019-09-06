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
  file.managed:
    - name: /etc/apt/sources.list.d/Devel_Uyuni_BuildRepo.list
    - source: salt://repos/repos.d/Devel_Uyuni_BuildRepo.list
    - template: jinja

{% endif %}
{% endif %}
{% endif %}

# HACK: work around #10852
{{ sls }}_nop:
  test.nop: []

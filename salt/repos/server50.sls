{% if 'server_containerized' in grains.get('roles')  %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SLE Micro' %}


manager50_repo:
  pkgrepo.managed:
    - baseurl: http://download.suse.de/ibs/SUSE:/SLE-15-SP5:/Update:/Products:/Manager50/images/repo/SUSE-Manager-Server-5.0-POOL-x86_64-Media1
    - refresh: True
    - gpgkey: http://download.suse.de/ibs/SUSE:/SLE-15-SP5:/Update:/Products:/Manager50/images/repo/SUSE-Manager-Server-5.0-POOL-x86_64-Media1/repodata/repomd.xml.key

{% endif %}
{% endif %}
{% endif %}


# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []


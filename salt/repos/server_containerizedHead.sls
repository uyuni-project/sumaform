{% if 'server_containerized' in grains.get('roles')  %}

{% if grains.get("os") == 'SUSE' %}
{% if grains['osfullname'] == 'SLE Micro' %}


server_devel_repo:
  pkgrepo.managed:
    # 5.0 should probably become 5.1 in the following URLs:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/SUSE-Manager-Server-5.0-POOL-x86_64-Media1/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head/images/repo/SUSE-Manager-Server-5.0-POOL-x86_64-Media1/repodata/repomd.xml.key

{% endif %}
{% endif %}
{% endif %}


# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []


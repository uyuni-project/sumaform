{% if 'server_containerized' in grains.get('roles')  %}

{% if grains.get("os") == "SUSE" %}
{% if grains['osfullname'] == 'openSUSE Leap Micro' %}
{% set repo = 'openSUSE_Leap_Micro_5.5' %}


{% if 'uyuni' == grains['product_version'] %}
# Commented out because we already add this repo in combustion:
# containerutils_uyuni_stable:
#     pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/{{ repo }}/
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key
{% endif %}

{% if 'uyuni-master' == grains.get('product_version') %}
# Commented out because we already add this repo in combustion:
# containerutils_uyuni_master:
#     pkgrepo.managed:
#     - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/
#     - refresh: True
#     - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key
{% endif %}


{% endif %}

{% if grains['osfullname'] == 'Leap' %}
{% set repo = 'openSUSE_Leap_15.6' %}


{% if 'uyuni' == grains['product_version'] %}
containerutils_uyuni_stable:
    pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/{{ repo }}/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key
{% endif %}

{% if 'uyuni-master' == grains.get('product_version') %}
containerutils_uyuni_master:
    pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/
    - refresh: True
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/ContainerUtils/{{ repo }}/repodata/repomd.xml.key
{% endif %}


{% endif %}

{% endif %}
{% endif %}


# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []


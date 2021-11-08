{% if 'jenkins' in grains.get('roles') %}
  {% if grains['os'] == 'SUSE' %}
    {% if grains['osfullname'] == 'Leap' %}
      {% set repo = 'openSUSE_Leap_' + grains['osrelease'] %}
    {% elif grains['osfullname'] == 'SLES' %}
      {% set slemajorver = grains['osrelease'].split('.')[0] %}
      {% set slesp = grains['osrelease'].split('.')[1] %}
      {% if slesp == '0' %}
        {% set slever = 'SLE_' + slemajorver %}
      {% else %}
        {% set slever = 'SLE_' + slemajorver + '_' + slesp %}
      {% endif %}
    {% endif %}
  {% endif %}
jenkins_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org/", true) }}/repositories/devel:/tools:/building/{{ repo }}
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org/", true) }}/repositories/devel:/tools:/building//{{ repo }}/repodata/repomd.xml.key
{% endif %}


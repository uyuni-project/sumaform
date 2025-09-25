include:
  - default
{% if grains['osfullname'] != 'openSUSE Tumbleweed' %}
  - .salt_bundle_package
{% endif %}
{% if (grains['osfullname'] in ['SL-Micro', 'Leap', 'openSUSE Tumbleweed']
       or (grains['osfullname'] == 'SLES' and grains['osrelease_info'][0] == 15)) %}
{% if not (grains['osfullname'] in ['SL-Micro', 'Leap'] and grains['osrelease'] == '6.2') %}
  - .salt_classic_package
{% endif %}
{% endif %}
  - .postinstallation

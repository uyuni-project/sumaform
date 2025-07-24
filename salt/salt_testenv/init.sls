include:
  - default
{% if grains['osfullname'] != 'openSUSE Tumbleweed' %}
  - .salt_bundle_package
{% endif %}
{% if (grains['osfullname'] in ['SL-Micro', 'Leap', 'openSUSE Tumbleweed']
       or (grains['osfullname'] == 'SLES' and grains['osrelease_info'][0] == 15)) %}
  - .salt_classic_package
{% endif %}
  - .postinstallation

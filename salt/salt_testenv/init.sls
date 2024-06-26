include:
  - default
{% if grains['osfullname'] == 'SLES' and grains['osrelease_info'][0] == 15 %}
  - .salt_classic_package
  - .salt_bundle_package
{% elif grains['osfullname'] == 'SLES' and grains['osrelease_info'][0] == 12 %}
  - .salt_bundle_package
{% elif grains['osfullname'] == 'SL-Micro' %}
  - .salt_classic_package
  - .salt_bundle_package
{% elif grains['osfullname'] == 'Leap' %}
  - .salt_classic_package
  - .salt_bundle_package
{% elif grains['osfullname'] == 'openSUSE Tumbleweed' %}
  - .salt_classic_package
{% elif grains['os'] == 'Debian' %}
  {% if grains['osrelease'] == '10' %}
  - .salt_classic_package
  - .salt_bundle_package
  {% else %}
  - .salt_bundle_package
  {% endif %}
{% elif grains['osfullname'] == 'Ubuntu' %}
  {% if grains['osrelease'] == '20.04' %}
  - .salt_classic_package
  - .salt_bundle_package
  {% else %}
  - .salt_bundle_package
  {% endif %}
{% elif grains['osfullname'] == 'AlmaLinux' %}
  {% if grains['osrelease_info'][0] == 8 %}
  - .salt_classic_package
  - .salt_bundle_package
  {% else %}
  - .salt_bundle_package
  {% endif %}
{% elif grains['osfullname'] == 'CentOS Linux' %}
  - .salt_bundle_package
{% else %}
    {{ raise("Salt Shaker unsupported OS") }}
{% endif %}
  - .postinstallation

include:
  - server_containerized.install_common

{% if grains['osfullname'] not in ['SLE Micro', 'SL-Micro', 'openSUSE Leap Micro'] %}

## We found a problem with the conmon package that triggers two errors: it overloads the HW of the 
##  host machine and the Uyuni CI gets stuck. Then we decided to downgrade the version of this
##  package meanwhile we file a bug of it to TW and the issue is solved.
{% if grains['osfullname'] == 'openSUSE Tumbleweed' %}

remove_conmon_2.2.x:
  pkg.removed:
    - name: conmon

install_conmon_2.1.x:
  pkg.installed:
    - sources:
      - conmon: salt://server_containerized/conmon-2.1.13-2.1.x86_64.rpm

{% endif %}

podman_packages:
  pkg.installed:
    - pkgs:
      - podman
      - netavark
      - aardvark-dns
    - require:
      {% if 'build_image' not in grains.get('product_version') | default('', true) %}
      - sls: repos
      {% endif %}
{% endif %}

{% if 'paygo' not in grains.get('product_version') | default('', true) %}
podman_login:
  cmd.run:
    - name: podman login -u {{ grains.get('cc_username') }} -p {{ grains.get('cc_password') }} {{ grains.get("container_repository") }}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

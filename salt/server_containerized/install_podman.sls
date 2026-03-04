include:
  - server_containerized.install_common

{% if grains['osfullname'] not in ['SLE Micro', 'SL-Micro', 'openSUSE Leap Micro'] %}

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

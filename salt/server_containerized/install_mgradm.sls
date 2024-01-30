include:
  - server_containerized.install_{{ grains.get('container_runtime') | default('podman', true) }}

mgradm_config:
  file.managed:
    - name: /root/mgradm.yaml
    - source: salt://server_containerized/mgradm.yaml
    - template: jinja

{% set runtime = grains.get('container_runtime') | default('podman', true) %}
{% set install_cmd = 'kubernetes' if runtime == 'k3s' else 'podman' %}

mgradm_install:
  cmd.run:
    - name: mgradm install {{ install_cmd }} --logLevel=debug --config /root/mgradm.yaml {{ grains.get("fqdn") }}
    - env:
      - KUBECONFIG: /etc/rancher/k3s/k3s.yaml
{%- if grains.get('container_runtime') | default('podman', true) == 'podman' %}
    - unless: podman ps | grep uyuni-server
{%- else %}
    - unless: helm --kubeconfig /etc/rancher/k3s/k3s.yaml list | grep uyuni
{%- endif %}
    - require:
{% if grains['osfullname'] != 'SLE Micro' %}
      - pkg: uyuni-tools
{% endif %}
      - sls: server_containerized.install_common
      - sls: server_containerized.install_{{ grains.get('container_runtime') | default('podman', true) }}
      - file: mgradm_config


include:
  - server_containerized.install_{{ grains.get('container_runtime') | default('podman', true) }}

uyuniadm_config:
  file.managed:
    - name: /root/uyuniadm.yaml
    - source: salt://server_containerized/uyuniadm.yaml
    - template: jinja

{% set runtime = grains.get('container_runtime') | default('podman', true) %}
{% set install_cmd = 'kubernetes' if runtime == 'k3s' else 'podman' %}

uyuniadm_install:
  cmd.run:
    - name: uyuniadm install {{ install_cmd }} --logLevel=debug --config /root/uyuniadm.yaml {{ grains.get("fqdn") }}
    - env:
      - KUBECONFIG: /etc/rancher/k3s/k3s.yaml
{%- if grains.get('container_runtime') | default('podman', true) == 'podman' %}
    - unless: podman ps | grep uyuni-server
{%- else %}
    - unless: helm --kubeconfig /etc/rancher/k3s/k3s.yaml list | grep uyuni
{%- endif %}
    - require:
      - pkg: uyuni-tools
      - sls: server_containerized.install_common
      - sls: server_containerized.install_{{ grains.get('container_runtime') | default('podman', true) }}
      - file: uyuniadm_config


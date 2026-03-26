{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu', 'openSUSE Tumbleweed', 'SLES'] %}
{% set pkg_map = {
    'openSUSE Tumbleweed': 'iptables'
} %}

{% if osfullname in pkg_map %}
install_dependencies_traefik:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

copy_traefik_installation_file:
  file.managed:
  - name: /root/kubernetes-crd-definition-v1.yml
  - source: salt://kubernetes_common/kubernetes-crd-definition-v1.yml
  - makedirs: true

install_traefik:
  cmd.run:
    - name: kubectl apply -f /root/kubernetes-crd-definition-v1.yml
    - env:
      - KUBECONFIG: {{ kubeconfig }}

{% endif %}

{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}
{% if is_supported_os %}
{% set pkg_map = {
    'openSUSE Tumbleweed': ['iptables']
} %}

{% if osfullname in pkg_map %}
install_dependencies_traefik:
  pkg.latest:
    - pkgs: {{ pkg_map.get(osfullname) }}
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

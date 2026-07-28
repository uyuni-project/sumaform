{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}
{% set traefik_file = "/root/kubernetes-crd-definition-v1.yml" %}
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
  - name: {{ traefik_file }}
  - source: salt://kubernetes_common/kubernetes-crd-definition-v1.yml
  - makedirs: true

{% if not is_slmicro_6_2 %}
install_traefik:
  cmd.run:
    - name: kubectl apply -f {{ traefik_file }}
    - env:
      - KUBECONFIG: {{ kubeconfig }}
{% endif %}

variables_traefik:
  file.managed:
    - name: /etc/profile.d/traefik_vars.sh
    - contents: |
        export TRAEFIK_PATH={{ traefik_file }}

{% endif %}

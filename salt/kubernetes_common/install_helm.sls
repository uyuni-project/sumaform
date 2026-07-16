{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}
{% if is_supported_os %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_version = "v1.19.2" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set pkg_map = {
    'Ubuntu': ['python3-yaml'],
    'openSUSE Tumbleweed': ['openssl', 'git'],
    'SUSE Linux Micro': ['git']
} %}

{% if osfullname in pkg_map %}
install_dependencies_helm:
  pkg.latest:
    - pkgs: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

helm_install_package:
  cmd.run:
    - name: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

{% if grains.get('install_cert_manager') == true and grains.get('install_rke2') == true %}

install_cert_manager:
  cmd.run:
    - name: |
        helm install \
          cert-manager oci://quay.io/jetstack/charts/cert-manager \
          --version {{ cert_manager_version }} \
          --namespace {{ cert_manager_namespace }} \
          --create-namespace \
          --set crds.enabled=true \
          --timeout 10m0s \
          --wait
    - env:
        - KUBECONFIG: {{ kubeconfig }}

check_cert_manager_installation:
  cmd.run:
    - name: 'helm status cert-manager --namespace {{ cert_manager_namespace }} | grep -q "STATUS: deployed"'
    - env:
        - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_cert_manager

install_trust_manager:
  cmd.run:
    - name: |
        helm upgrade trust-manager oci://quay.io/jetstack/charts/trust-manager \
          --install \
          --namespace {{ cert_manager_namespace }} \
          --wait
    - env:
        - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_cert_manager

check_trust_manager_installation:
  cmd.run:
    - name: 'helm status trust-manager --namespace {{ cert_manager_namespace }} | grep -q "STATUS: deployed"'
    - env:
        - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_trust_manager

{% endif %}

{% endif %}

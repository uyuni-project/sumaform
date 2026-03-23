{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu', 'openSUSE Tumbleweed', 'SLES'] %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_version = "v1.19.2" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set pkg_map = {
    'Ubuntu': 'python3-yaml',
    'openSUSE Tumbleweed': 'openssl'
} %}

{% if osfullname in pkg_map %}
install_dependencies_helm:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

helm_install_package:
  cmd.run:
    - name: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

install_cert_manager:
  cmd.run:
    - name: |
        helm install \
          cert-manager oci://quay.io/jetstack/charts/cert-manager \
          --version {{ cert_manager_version }} \
          --namespace {{ cert_manager_namespace }} \
          --create-namespace \
          --set crds.enabled=true \
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

check_trust_manager_installation:
  cmd.run:
    - name: 'helm status trust-manager --namespace {{ cert_manager_namespace }} | grep -q "STATUS: deployed"'
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_trust_manager

{% endif %}

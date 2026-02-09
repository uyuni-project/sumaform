{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu'] %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_version = "v1.19.2" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set pkg_map = {
    'Ubuntu': 'python3-yaml'
} %}

{% if pkg_map.get(osfullname) != '' %}
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

install_trust_manager:
  cmd.run:
    - name: |
        helm upgrade trust-manager oci://quay.io/jetstack/charts/trust-manager \
          --install \
          --namespace {{ cert_manager_namespace }} \
          --wait
    - env:
      - KUBECONFIG: {{ kubeconfig }}

{% endif %}

{% set kubeconfig = "/root/.kube/config" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set cert_manager_version = "v1.19.2" %}

include:
  - server_kubernetes.install_kubernetes_server

install_external_kubernetes_dependencies:
  pkg.installed:
    - pkgs:
      - python3-PyYAML

external_kubernetes_kubeconfig:
  file.exists:
    - name: {{ kubeconfig }}
    {% if grains.get('kubeconfig_content') %}
    - require:
      - cmd: write_kubeconfig
    {% endif %}

{% if grains.get('install_cert_manager') == true %}
install_cert_manager_on_external_kubernetes:
  cmd.run:
    - name: |
        helm upgrade --install \
          cert-manager oci://quay.io/jetstack/charts/cert-manager \
          --version {{ cert_manager_version }} \
          --namespace {{ cert_manager_namespace }} \
          --create-namespace \
          --set crds.enabled=true \
          --wait
    - unless: KUBECONFIG={{ kubeconfig }} helm status cert-manager --namespace {{ cert_manager_namespace }}
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_helm_on_controller
      - file: external_kubernetes_kubeconfig

install_trust_manager_on_external_kubernetes:
  cmd.run:
    - name: |
        helm upgrade --install \
          trust-manager oci://quay.io/jetstack/charts/trust-manager \
          --namespace {{ cert_manager_namespace }} \
          --wait
    - unless: KUBECONFIG={{ kubeconfig }} helm status trust-manager --namespace {{ cert_manager_namespace }}
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_helm_on_controller
      - file: external_kubernetes_kubeconfig
{% endif %}

create_external_kubernetes_uyuni_namespace:
  cmd.run:
    - name: kubectl create namespace uyuni
    - unless: KUBECONFIG={{ kubeconfig }} kubectl get namespace uyuni
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - pkg: install_kubectl
      - file: external_kubernetes_kubeconfig
      {% if grains.get('install_cert_manager') == true %}
      - cmd: install_cert_manager_on_external_kubernetes
      - cmd: install_trust_manager_on_external_kubernetes
      {% endif %}

{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}

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

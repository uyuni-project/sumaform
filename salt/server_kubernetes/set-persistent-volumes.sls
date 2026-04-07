{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}

create_uyuni_namespace:
  cmd.run: 
  - name: kubectl create namespace uyuni
  - env:
    - KUBECONFIG: {{ kubeconfig }}

copy_var_spacewalk_file:
  file.managed:
    - name: /root/volume-configuration-var-spacewalk.yml
    - source: salt://server_kubernetes/volume-configuration-var-spacewalk.yml

apply_var_spacewalk_file:
  cmd.run:
    - name: kubectl apply -f /root/volume-configuration-var-spacewalk.yml
    - env:
      - KUBECONFIG: {{ kubeconfig }}

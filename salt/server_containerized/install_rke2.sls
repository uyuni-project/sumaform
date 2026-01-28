include:
  - server_containerized.install_common

{% if grains['osfullname'] in ['SLE Micro', 'SL-Micro', 'openSUSE Leap Micro', 'openSUSE Tumbleweed', 'Ubuntu'] %}
{% set rke2_version = "v1.34.2+rke2r1" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_url = "https://github.com/cert-manager/cert-manager/releases/download/v1.19.2/cert-manager.yaml" %}

tls-san_setup_file:
  file.managed:
    - name: /etc/rancher/rke2/config.yaml
    - contents: |
        tls-san:
          - "{{ grains.get("fqdn") }}"
    - makedirs: True

rke2_install:
  cmd.run:
    - name: curl -sfL https://get.rke2.io | sh -
    - env:
      - INSTALL_RKE2_VERSION: "{{ rke2_version }}"

rke2_server_start_and_enable:
  service.running:
    - name: rke2-server
    - enable: True

link_kubectl_rke2:
  file.symlink:
    - name: /usr/local/bin/kubectl
    - target: /var/lib/rancher/rke2/bin/kubectl
    - force: True
    - makedirs: True

link_crictl_rke2:
  file.symlink:
    - name: /usr/local/bin/crictl
    - target: /var/lib/rancher/rke2/bin/crictl
    - force: True
    - makedirs: True

link_ctr_rke2:
  file.symlink:
    - name: /usr/local/bin/ctr
    - target: /var/lib/rancher/rke2/bin/ctr
    - force: True
    - makedirs: True

variabls_rke2:
  file.managed:
    - name: /etc/profile.d/rke2_vars.sh
    - contents: |
        export PATH=$PATH:/opt/rke2/bin
        export KUBECONFIG={{ kubeconfig }}

install_cert-manager:
  cmd.run:
    - name: kubectl apply -f {{ cert_manager_url }}
    - env: 
      - KUBECONFIG: {{ kubeconfig }}

## In principle traefik is not going to be used as an ingress method in our rke2 implementation but let's wait until we have the helm chart to delete it
# wait_for_traefik:
#  cmd.script:
#    - name: salt://server_containerized/wait_for_kube_resource.py
#    - args: kube-system deploy traefik
#    - use_vt: True
#    - template: jinja
#    - require:
#      - cmd: k3s_install 

openssl_install:
  pkg.installed:
    - name: openssl
    - version: latest
    - refresh: True

helm_install_package:
  cmd.run:
    - name: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

{%- set mirror_hostname = grains.get('server_mounted_mirror') if grains.get('server_mounted_mirror') else grains.get('mirror') %}
{% if mirror_hostname %}
mirror_pv_file:
  file.managed:
    - name: /root/mirror-pv.yaml
    - source: salt://server_containerized/mirror-pv.yaml
    - template: jinja

mirror_pv_deploy:
  cmd.run:
    - name: kubectl apply -f /root/mirror-pv.yaml
    - env: 
      - KUBECONFIG: {{ kubeconfig }}
    - unless: kubectl get pv mirror
    - require:
      - file: mirror_pv_file
    
{% endif %}

{% endif %}

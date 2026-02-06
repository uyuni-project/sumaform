{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu'] %}
{% set helm_chart_certificate_path = "/root/helm-charts" %}
{% set cert_manager_version = "v1.19.2" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set rke2_namespace = "kube-system" %}
{% set values_yaml_path = helm_chart_certificate_path ~ "/selfsigned/values.yaml" %}
{% set self_signed_path = helm_chart_certificate_path ~ "/selfsigned" %}
{% set pkg_map = {
    'Ubuntu': 'python3-yaml'
} %}

{% if pkg_map.get(osfullname) != '' %}
install_dependencies_helm:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

clone_uyuni_charts_repo:
  git.latest:
    - name: https://github.com/uyuni-project/uyuni-charts.git
    - target: {{ helm_chart_certificate_path }}
    - user: root

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

copy_manifest:
  file.managed:
    - name: /var/lib/rancher/rke2/server/manifests/uyuni-ingress.yaml
    - source: salt://server_containerized/uyuni-ingress.yaml
    - template: jinja
    - defaults:
        namespace: {{ rke2_namespace }}

copy_traefik_installation_file:
  file.managed:
  - name: /root/kubernetes-crd-definition-v1.yml
  - source: salt://server_containerized/kubernetes-crd-definition-v1.yml
  - makedirs: true

# In principle we are not using Traefik as an ingress controller, but it has dependencies in common and fails if isen't installed
install_traefik:
  cmd.run:
    - name: kubectl apply -f /root/kubernetes-crd-definition-v1.yml
    - env:
      - KUBECONFIG: {{ kubeconfig }}

copy_local-path-storage_installation_file:
  file.managed:
  - name: /root/local-path-storage.yaml
  - source: salt://server_containerized/local-path-storage.yaml
  - makedirs: true

### Even if we decided to use local_path_provisioner, we agreed in having var-spacewalk and var-pgsql in separated volumes
##### Pending to add var-spacewalk and var-pgsql in different volumes
install_local_path_provisioner:
  cmd.run:
    - name: kubectl apply -f /root/local-path-storage.yaml
    - env:
      - KUBECONFIG: {{ kubeconfig }}

set_local-path-storage-file-as-default:
  cmd.run:
    - name: |
        kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    - env:
      - KUBECONFIG: {{ kubeconfig }}

transfer_python_management_file:
  file.managed:
  - name: /root/helm_chart.py
  - source: salt://server_containerized/helm_chart.py
  - makedirs: true

update_oci_app_version:
  cmd.run:
  - name: python3 /root/helm_chart.py -p {{ self_signed_path }}/Chart.yaml

##### Probably we'll have to test it with Traefik as ingress controller instead of NGINX, but at the moment it just works with NGINX
######### Beginning of the NGINX related blocks

fullfill_traefik:
  file.replace:
    - name: {{ values_yaml_path }}
    - pattern: 'fqdn:.*'
    - repl: |
        fqdn:
        traefik:
          enabled: false

fullfill_fqdn:
  file.replace:
    - name: {{ values_yaml_path }}
    - pattern: 'fqdn:.*'
    - repl: |
        fqdn: "{{ grains.get("fqdn") }}"
          ingress:
            enabled: true
            className: nginx

fullfill_passwords_fields:
  file.replace:
    - name: {{ values_yaml_path }}
    - pattern: 'password:.*'
    - repl: 'password: admin'
    - flags: ['MULTILINE']

######### End of the NIGINX related blocks

build_helm_dependencies:
  cmd.run:
  - name: helm dependencies build
  - cwd: {{ self_signed_path }}

install_uyuni_on_kubernetes:
  cmd.run:
  - name: helm upgrade --install uyuni ./selfsigned -f ./selfsigned/values.yaml -n {{ rke2_namespace }}
  - cwd: {{ helm_chart_certificate_path }}
  - env:
    - KUBECONFIG: {{ kubeconfig }}

{% endif %}

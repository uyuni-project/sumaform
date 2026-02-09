{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu'] %}
{% set helm_chart_certificate_path = "/root/helm-charts" %}
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

copy_helm_charts_directory:
  file.managed:
    - name: {{ helm_chart_certificate_path }}
    - source: salt://server_containerized/server-selfsigned
    - user: root
    - defaults:
        pass_product: admin
        pass_db: admin
        pass_postgres: admin
        pass_reportdb: admin
        fqdn: grains.get("fqdn")
        version: 5.2.0
        oci_name: server_helm
        oci_repository: grains.get("helm_chart_url")


copy_manifest_uyuni_ingress:
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

### Even if we decided to use local_path_provisioner, we agreed in having var-spacewalk and var-pgsql in separated volumes
##### Pending to add var-spacewalk and var-pgsql in different volumes

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

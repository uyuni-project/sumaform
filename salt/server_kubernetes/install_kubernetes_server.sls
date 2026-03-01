{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu'] %}
{% set helm_chart_certificate_path = "/root/helm-charts" %}
{% set values_yaml_path = helm_chart_certificate_path ~ "/selfsigned/values.yaml" %}
{% set self_signed_path = helm_chart_certificate_path ~ "/selfsigned" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set rke2_namespace = "kube-system" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set helm_chart_name = grains.get('helm_chart_name') %}
{% set helm_chart_url = grains.get('helm_chart_url') %}
{% set oci_vars_path = "/etc/profile.d/oci_var.sh" %}
{% set python_helm_chart_path = "/root/helm_chart.py" %}


{% set pkg_map = {
    'Ubuntu': 'python3-yaml'
} %}

{% if pkg_map.get(osfullname) != '' %}
install_dependencies_helm_server:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

copy_helm_charts_directory:
  file.recurse:
    - name: {{ self_signed_path }}
    - source: salt://server_kubernetes/server-selfsigned
    - user: root

copy_value_yaml_file:
  file.managed:
    - name: {{ self_signed_path }}/values.yaml
    - source: salt://server_kubernetes/values_server.yaml
    - template: jinja
    - context:
        pass_product: admin
        pass_db: admin
        pass_postgres: admin
        pass_reportdb: admin
        fqdn: {{ grains.get("fqdn") }}
        cert_manager_namespace: {{ cert_manager_namespace }}
        container_repository: {{ grains.get("container_repository")}}

copy_chart_yaml_file:
  file.managed:
    - name: {{ self_signed_path }}/Chart.yaml
    - source: salt://server_kubernetes/Chart_server.yaml
    - template: jinja
    - context:
        oci_name: {{ helm_chart_name }}
        oci_repository: {{ helm_chart_url }}


copy_manifest_uyuni_ingress:
  file.managed:
    - name: /var/lib/rancher/rke2/server/manifests/uyuni-ingress.yaml
    - source: salt://server_kubernetes/uyuni-ingress.yaml
    - template: jinja
    - defaults:
        namespace: {{ rke2_namespace }}

copy_traefik_installation_file:
  file.managed:
  - name: /root/kubernetes-crd-definition-v1.yml
  - source: salt://server_kubernetes/kubernetes-crd-definition-v1.yml
  - makedirs: true

# In principle we are not using Traefik as ingress controller, but it has dependencies in common and fails if isn't installed
install_traefik:
  cmd.run:
    - name: kubectl apply -f /root/kubernetes-crd-definition-v1.yml
    - env:
      - KUBECONFIG: {{ kubeconfig }}


### Even if we decided to use local_path_provisioner, we agreed in having var-spacewalk and var-pgsql in separated volumes
##### Pending to add var-spacewalk and var-pgsql in different volumes

transfer_python_management_file:
  file.managed:
  - name: {{ python_helm_chart_path }}
  - source: salt://kubernetes_common/helm_chart.py
  - makedirs: true

update_oci_app_version:
  cmd.run:
  - name: python3 {{ python_helm_chart_path }} -o {{ helm_chart_url }}/{{ helm_chart_name }} -f {{ oci_vars_path }} --chart-file {{ self_signed_path }}/Chart.yaml

apply_oci_variables:
  cmd.run:
  - name: source {{ oci_vars_path }}

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
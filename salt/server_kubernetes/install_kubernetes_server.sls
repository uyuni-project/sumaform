{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu', 'openSUSE Tumbleweed', 'SLES'] %}
{% set helm_chart_directory = "/root/helm-charts" %}
{% set values_yaml_path = helm_chart_directory ~ "/selfsigned/values.yaml" %}
{% set self_signed_path = helm_chart_directory ~ "/selfsigned" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set helm_chart_name = grains.get('helm_chart_name') %}
{% set helm_chart_url = grains.get('helm_chart_url') %}
{% set oci_vars_path = "/etc/profile.d/oci_var.sh" %}
{% set python_helm_chart_path = "/root/helm_chart.py" %}
{% set devel_flag = "--devel" if grains.get('use_devel_oci') else "" %}

# For future packages
{% set pkg_map = {} %}

{% if osfullname in pkg_map %}
install_dependencies_helm_server:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

copy_traefik_installation_file:
  file.managed:
  - name: /root/kubernetes-crd-definition-v1.yml
  - source: salt://server_kubernetes/kubernetes-crd-definition-v1.yml
  - makedirs: true

install_traefik:
  cmd.run:
    - name: kubectl apply -f /root/kubernetes-crd-definition-v1.yml
    - env:
      - KUBECONFIG: {{ kubeconfig }}

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

transfer_python_management_file:
  file.managed:
  - name: {{ python_helm_chart_path }}
  - source: salt://kubernetes_common/helm_chart.py
  - makedirs: true

update_oci_app_version:
  cmd.run:
  - name: python3 {{ python_helm_chart_path }} -o {{ helm_chart_url }}/{{ helm_chart_name }} -f {{ oci_vars_path }} --chart-file {{ self_signed_path }}/Chart.yaml {{ devel_flag }}

build_helm_dependencies:
  cmd.run:
  - name: helm dependencies build
  - cwd: {{ self_signed_path }}

create_uyuni_namespace:
  cmd.run: 
  - name: kubectl create namespace uyuni
  - env:
    - KUBECONFIG: {{ kubeconfig }}

install_uyuni_on_kubernetes:
  cmd.run:
  - name: helm upgrade --install uyuni ./selfsigned -f ./selfsigned/values.yaml -n uyuni
  - cwd: {{ helm_chart_directory }}
  - env:
    - KUBECONFIG: {{ kubeconfig }}

{% endif %}

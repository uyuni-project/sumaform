{% set osfullname = grains['osfullname'] %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set rke2_namespace = "kube-system" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set helm_chart_name = grains.get('helm_chart_name') %}
{% set helm_chart_url = grains.get('helm_chart_url') %}
{% set python_helm_chart_path = "/root/helm_chart.py" %}
{% set oci_vars_path = "/etc/profile.d/oci_var.sh" %}
{% set self_signed_path = "/root/helm-charts/selfsigned" %}

{% if osfullname in ['Ubuntu'] %}

{% set pkg_map = {
    'Ubuntu': ''
} %}

{% if pkg_map.get(osfullname) != '' %}
install_dependencies_helm_proxy:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}


copy_manifest_uyuni_ingress_proxy:
  file.managed:
    - name: /var/lib/rancher/rke2/server/manifests/uyuni_ingress_proxy.yaml
    - source: salt://proxy_kubernetes/uyuni_ingress_proxy.yaml
    - template: jinja
    - defaults:
        namespace: {{ rke2_namespace }}

mkdir_helm_dir:
  cmd.run:
    - name: mkdir -p {{ self_signed_path }}

copy_chart_proxy:
  file.managed:
    - name: {{ self_signed_path }}/Chart.yaml
    - source: salt://proxy_kubernetes/Chart_proxy.yaml
    - template: jinja
    - context:
        oci_name: {{ helm_chart_name }}
        oci_repository: {{ helm_chart_url }}

copy_values_proxy:
  file.managed:
    - name: {{ self_signed_path }}/values.yaml
    - source: salt://proxy_kubernetes/values_proxy.yaml
    - template: jinja
    - context:
      fqdn: {{ grains.get("fqdn")}}
      cert_manager_namespace: {{ cert_manager_namespace}}
      container_repository:  {{ grains.get("container_repository")}}

transfer_python_management_file:
  file.managed:
  - name: {{ python_helm_chart_path }}
  - source: salt://kubernetes_common/helm_chart.py
  - makedirs: true

update_oci_app_version_proxy:
  cmd.run:
  - name: python3 {{ python_helm_chart_path }} -o {{ helm_chart_url }}/{{ helm_chart_name }} -f {{ oci_vars_path }} --chart-file {{ self_signed_path }}/Chart.yaml

apply_oci_variables_proxy:
  cmd.run:
  - name: source {{ oci_vars_path }}

##### It just prepares the test bed to install a proxy, in following PR the installation of the proxy by itself will be added in new blocks
{% endif %}

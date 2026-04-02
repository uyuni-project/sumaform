{% set osfullname = grains['osfullname'] %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set helm_chart_directory = "/root/helm-charts" %}
{% set values_yaml_path = helm_chart_directory ~ "/selfsigned/values.yaml" %}
{% set self_signed_path = helm_chart_directory ~ "/selfsigned" %}
{% set helm_chart_name = grains.get('helm_chart_name') %}
{% set helm_chart_url = grains.get('helm_chart_url') %}
{% set python_helm_chart_path = "/root/helm_chart.py" %}
{% set devel_flag = "--devel" if grains.get('use_devel_oci') else "" %}


{% if osfullname in ['Ubuntu', 'openSUSE Tumbleweed', 'SLES'] %}

{% set pkg_map = {
  'openSUSE Tumbleweed' : 'jq'
} %}

{% if osfullname in pkg_map %}
install_dependencies_helm_proxy:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}


copy_manifest_uyuni_ingress_proxy:
  file.managed:
    - name: /var/lib/rancher/rke2/server/manifests/uyuni_ingress_proxy.yaml
    - source: salt://proxy_kubernetes/uyuni_ingress_proxy.yaml

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
  - name: python3 {{ python_helm_chart_path }} -o {{ helm_chart_url }}/{{ helm_chart_name }} --chart-file {{ self_signed_path }}/Chart.yaml {{ devel_flag }}

 {% if grains.get('install_mlm_proxy') == true %}

build_helm_dependencies:
  cmd.run:
  - name: helm dependencies build
  - cwd: {{ self_signed_path }}

copy_config_tar:
  cmd.run:
  - name: cp -r /root/config.tar.gz {{ helm_chart_directory }}

uncompress_config_tar:
  cmd.run:
  - name: tar -xf {{ helm_chart_directory }}/config.tar.gz -C {{ helm_chart_directory }}/
  - cwd: {{ helm_chart_directory }}

install_uyuni_on_kubernetes:
  cmd.run:
  - name: helm upgrade --install uyuni ./selfsigned -f ./selfsigned/values.yaml -n uyuni --set-file global.ssh=ssh.yaml --set-file global.config=config.yaml --set-file global.httpd=httpd.yaml
  - cwd: {{ helm_chart_directory }}
  - env:
    - KUBECONFIG: {{ kubeconfig }}


{% endif %}

{% endif %}

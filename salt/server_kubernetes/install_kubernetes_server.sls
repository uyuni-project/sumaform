{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu', 'openSUSE Tumbleweed', 'SLES'] %}
{% set helm_chart_directory = "/root/helm-charts" %}
{% set values_yaml_path = helm_chart_directory ~ "/selfsigned/values.yaml" %}
{% set self_signed_path = helm_chart_directory ~ "/selfsigned" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set helm_chart_full = grains.get('helm_chart_url') %}
{% set helm_chart_parts = helm_chart_full.rsplit('/', 1) %}
{% set helm_chart_repository = helm_chart_parts[0] %}
{% set helm_chart_name = helm_chart_parts[1] %}
{% set python_helm_chart_path = "/root/helm_chart.py" %}
{% set devel_flag = "--devel" if grains.get('use_devel_oci') else "" %}

{% set pkg_map = {
  'openSUSE Tumbleweed' : 'jq'
} %}

{% if osfullname in pkg_map %}
install_dependencies_helm_server:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}


ssh_public_key_proxy_kubernetes_server_exchange:
  file.managed:
    - name: /root/.ssh/id_ed25519_proxy.pub
    - source: salt://proxy_kubernetes/proxy_keys/id_ed25519_proxy.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

key_exchange_kubernetes_server:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://proxy_kubernetes/proxy_keys/id_ed25519_proxy.pub
    - makedirs: True

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
        oci_repository: {{ helm_chart_repository }}


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
  - name: python3 {{ python_helm_chart_path }} -o {{ helm_chart_full }} --chart-file {{ self_signed_path }}/Chart.yaml {{ devel_flag }}

{% if grains.get('install_mlm_server') == true %}

build_helm_dependencies:
  cmd.run:
  - name: helm dependencies build
  - cwd: {{ self_signed_path }}

install_uyuni_on_kubernetes:
  cmd.run:
  - name: helm upgrade --install uyuni ./selfsigned -f ./selfsigned/values.yaml -n uyuni
  - cwd: {{ helm_chart_directory }}
  - env:
    - KUBECONFIG: {{ kubeconfig }}

save_pod_as_env_variable:
  cmd.run:
  - name: echo export Server_pod="$(kubectl get pods -n uyuni --no-headers | grep uyuni | grep -v setup | awk '{print $1}')" > /etc/profile.d/pod_server.sh
  - env:
    - KUBECONFIG: {{ kubeconfig }}

{% endif %}

{% endif %}

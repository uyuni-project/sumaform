{% set kubeconfig = "/root/.kube/config" %}
{% set helm_chart_directory = "/root/helm-charts" %}
{% set self_signed_path = helm_chart_directory ~ "/selfsigned" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set cert_manager_version = "v1.19.2" %}
{% set helm_chart_name = grains.get('kubernetes_server_helm_chart_name') or 'server-helm' %}
{% set helm_chart_url = grains.get('kubernetes_server_helm_chart_url') or 'oci://registry.suse.de/devel/galaxy/manager/head/charts/suse/multi-linux-manager/5.2' %}
{% set python_helm_chart_path = "/root/helm_chart.py" %}
{% set devel_flag = "--devel" if grains.get('use_devel_oci') else "" %}
{% set server_fqdn = grains.get('kubernetes_server_fqdn') or grains.get('server') %}
{% set container_repository = grains.get('kubernetes_server_container_repository') | default('', true) %}

install_external_kubernetes_dependencies:
  pkg.installed:
    - pkgs:
      - python3-PyYAML

external_kubernetes_kube_directory:
  file.directory:
    - name: /root/.kube
    - user: root
    - group: root
    - mode: 700

{% if grains.get('kubeconfig_content') %}
write_external_kubernetes_kubeconfig:
  cmd.run:
    - name: 'printf "%s" "{{ grains.get("kubeconfig_content") }}" | base64 -d > {{ kubeconfig }} && chmod 600 {{ kubeconfig }}'
    - require:
      - file: external_kubernetes_kube_directory
{% endif %}

external_kubernetes_kubeconfig:
  file.exists:
    - name: {{ kubeconfig }}
    - require:
      - file: external_kubernetes_kube_directory
      {% if grains.get('kubeconfig_content') %}
      - cmd: write_external_kubernetes_kubeconfig
      {% endif %}

{% if grains.get('install_cert_manager') == true %}
install_cert_manager_on_external_kubernetes:
  cmd.run:
    - name: |
        helm upgrade --install \
          cert-manager oci://quay.io/jetstack/charts/cert-manager \
          --version {{ cert_manager_version }} \
          --namespace {{ cert_manager_namespace }} \
          --create-namespace \
          --set crds.enabled=true \
          --wait
    - unless: KUBECONFIG={{ kubeconfig }} helm status cert-manager --namespace {{ cert_manager_namespace }}
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_helm_on_controller
      - file: external_kubernetes_kubeconfig

install_trust_manager_on_external_kubernetes:
  cmd.run:
    - name: |
        helm upgrade --install \
          trust-manager oci://quay.io/jetstack/charts/trust-manager \
          --namespace {{ cert_manager_namespace }} \
          --wait
    - unless: KUBECONFIG={{ kubeconfig }} helm status trust-manager --namespace {{ cert_manager_namespace }}
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_helm_on_controller
      - file: external_kubernetes_kubeconfig
{% endif %}

create_external_kubernetes_uyuni_namespace:
  cmd.run:
    - name: kubectl create namespace uyuni
    - unless: KUBECONFIG={{ kubeconfig }} kubectl get namespace uyuni
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - file: external_kubernetes_kubeconfig
      {% if grains.get('install_cert_manager') == true %}
      - cmd: install_cert_manager_on_external_kubernetes
      - cmd: install_trust_manager_on_external_kubernetes
      {% endif %}

copy_external_kubernetes_helm_charts_directory:
  file.recurse:
    - name: {{ self_signed_path }}
    - source: salt://server_kubernetes/server-selfsigned
    - user: root
    - group: root

copy_external_kubernetes_values_file:
  file.managed:
    - name: {{ self_signed_path }}/values.yaml
    - source: salt://server_kubernetes/values_server.yaml
    - template: jinja
    - context:
        pass_product: admin
        pass_db: admin
        pass_postgres: admin
        pass_reportdb: admin
        fqdn: {{ server_fqdn }}
        cert_manager_namespace: {{ cert_manager_namespace }}
        container_repository: "{{ container_repository }}"
        deploy_coco_attestation: {{ grains.get("deploy_coco_attestation") }}
        deploy_saline: {{ grains.get("deploy_saline") }}
        deploy_hub_api: {{ grains.get("deploy_hub_api") }}
        deploy_tftp: {{ grains.get("deploy_tftp") }}
        app_armor_name: ""
        selinuxType: ""
    - require:
      - file: copy_external_kubernetes_helm_charts_directory

copy_external_kubernetes_chart_file:
  file.managed:
    - name: {{ self_signed_path }}/Chart.yaml
    - source: salt://server_kubernetes/Chart_server.yaml
    - template: jinja
    - context:
        oci_name: {{ helm_chart_name }}
        oci_repository: {{ helm_chart_url }}
    - require:
      - file: copy_external_kubernetes_helm_charts_directory

transfer_external_kubernetes_helm_chart_helper:
  file.managed:
    - name: {{ python_helm_chart_path }}
    - source: salt://kubernetes_common/helm_chart.py
    - makedirs: true

update_external_kubernetes_oci_app_version:
  cmd.run:
    - name: python3 {{ python_helm_chart_path }} -o {{ helm_chart_url }}/{{ helm_chart_name }} --chart-file {{ self_signed_path }}/Chart.yaml {{ devel_flag }}
    - require:
      - cmd: install_helm_on_controller
      - file: transfer_external_kubernetes_helm_chart_helper
      - file: copy_external_kubernetes_chart_file
      - pkg: install_external_kubernetes_dependencies

build_external_kubernetes_helm_dependencies:
  cmd.run:
    - name: helm dependencies build
    - cwd: {{ self_signed_path }}
    - require:
      - cmd: update_external_kubernetes_oci_app_version

install_uyuni_server_on_external_kubernetes:
  cmd.run:
    - name: helm upgrade --install uyuni ./selfsigned -f ./selfsigned/values.yaml -n uyuni --create-namespace
    - cwd: {{ helm_chart_directory }}
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: build_external_kubernetes_helm_dependencies
      - cmd: create_external_kubernetes_uyuni_namespace
      - file: copy_external_kubernetes_values_file

save_external_kubernetes_server_pod_name_script:
  file.managed:
    - name: /usr/local/bin/get_server_pod_name
    - source: salt://controller/get_server_pod_name
    - template: jinja
    - mode: 700
    - user: root
    - group: root
    - require:
      - cmd: install_uyuni_server_on_external_kubernetes

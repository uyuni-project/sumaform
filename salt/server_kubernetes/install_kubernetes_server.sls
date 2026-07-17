{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{# In external cluster mode this state runs on the controller against /root/.kube/config, so RKE2 host specifics are skipped. #}
{% set is_external_cluster = grains.get('install_kubernetes_server_on_external_cluster') == true %}
{% set is_sles_15_7 = not is_external_cluster and osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = not is_external_cluster and osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = not is_external_cluster and osfullname == 'Ubuntu' %}
{% set is_tumbleweed = not is_external_cluster and osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}

{% if is_supported_os or is_external_cluster %}
{% set helm_chart_directory = "/root/helm-charts" %}
{% set values_yaml_path = helm_chart_directory ~ "/selfsigned/values.yaml" %}
{% set self_signed_path = helm_chart_directory ~ "/selfsigned" %}
{% set kubeconfig = "/root/.kube/config" if is_external_cluster else "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set cert_manager_version = "v1.19.2" %}
{% set helm_chart_name = grains.get('helm_chart_name') %}
{% set helm_chart_url = grains.get('helm_chart_url') %}
{% set python_helm_chart_path = "/root/helm_chart.py" %}
{% set devel_flag = "--devel" if grains.get('use_devel_oci') else "" %}
{% set server_fqdn = (grains.get('kubernetes_server_fqdn') or grains.get('server')) if is_external_cluster else grains.get('fqdn') %}

{% set pkg_map = {
  'openSUSE Tumbleweed' : 'jq'
} %}

{% if not is_external_cluster %}

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

{% else %}

install_external_kubernetes_dependencies:
  pkg.installed:
    - pkgs:
      - python3-PyYAML

external_kubernetes_kubeconfig:
  file.exists:
    - name: {{ kubeconfig }}
    {% if grains.get('kubeconfig_content') %}
    - require:
      # write_kubeconfig is defined in controller/init.sls, which includes this state
      - cmd: write_kubeconfig
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
      # install_helm_on_controller is defined in controller/init.sls, which includes this state
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
      # install_kubectl is defined in controller/init.sls, which includes this state
      - pkg: install_kubectl
      - file: external_kubernetes_kubeconfig
      {% if grains.get('install_cert_manager') == true %}
      - cmd: install_cert_manager_on_external_kubernetes
      - cmd: install_trust_manager_on_external_kubernetes
      {% endif %}

{% endif %}

copy_helm_charts_directory:
  file.recurse:
    - name: {{ self_signed_path }}
    - source: salt://server_kubernetes/server-selfsigned
    - user: root
    - group: root

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
        fqdn: {{ server_fqdn }}
        cert_manager_namespace: {{ cert_manager_namespace }}
        {% if is_external_cluster %}
        container_registry: "{{ grains.get("container_registry") | default('', true) }}"
        {% else %}
        container_registry: {{ grains.get("container_registry")}}
        {% endif %}
        deploy_coco_attestation: {{ grains.get("deploy_coco_attestation") }}
        coco_container_image: {{ grains.get("coco_container_image") }}
        coco_container_tag: {{ grains.get("coco_container_tag") }}
        deploy_saline: {{ grains.get("deploy_saline") }}
        saline_container_image: {{ grains.get("saline_container_image") }}
        saline_container_tag: {{ grains.get("saline_container_tag") }}
        deploy_hub_api: {{ grains.get("deploy_hub_api") }}
        hub_api_container_image: {{ grains.get("hub_api_container_image") }}
        hub_api_container_tag: {{ grains.get("hub_api_container_tag") }}
        deploy_tftp: {{ grains.get("deploy_tftp") }}
        tftpd_container_image: {{ grains.get("tftpd_container_image") }}
        tftpd_container_tag: {{ grains.get("tftpd_container_tag") }}
        app_armor_name: {{ 'k8s-systemd-uyuni' if is_sles_15_7 or is_ubuntu else '' }}
        selinuxType: {{ 'uyuni_container_t' if is_tumbleweed or is_slmicro_6_2 else '' }}

copy_chart_yaml_file:
  file.managed:
    - name: {{ self_signed_path }}/Chart.yaml
    - source: salt://server_kubernetes/Chart_server.yaml
    - template: jinja
    - context:
        oci_name: {{ helm_chart_name }}
        oci_repository: {{ helm_chart_url }}

{% if (grains.get('install_rke2') == true and grains.get('install_helm') == true) or is_external_cluster %}

{% if not is_external_cluster %}
copy_manifest_uyuni_ingress:
  file.managed:
    - name: /var/lib/rancher/rke2/server/manifests/uyuni-ingress.yaml
    - source: salt://server_kubernetes/uyuni-ingress.yaml
    - template: jinja
    - context:
        java_debugging_on_rke2: {{ grains.get("java_debugging_on_rke2", false) }}
{% endif %}

## Configure apparmor profile for RKE2

{% if is_sles_15_7 or is_ubuntu %}
configure_apparmor_profile_rke2:
  file.managed:
    - name: /etc/apparmor.d/k8s-systemd-uyuni
    - source: salt://server_kubernetes/k8s-systemd-uyuni

apply_apparmor_profile:
  cmd.run:
    - name: apparmor_parser -r /etc/apparmor.d/k8s-systemd-uyuni

{% endif %}

## Configure SELinux for RKE2

{% if is_tumbleweed or is_slmicro_6_2 %}

copy_systemdcontainerpolicy_te:
  file.managed:
    - name: /root/systemdcontainerpolicy.te
    - source: salt://server_kubernetes/systemdcontainerpolicy.te

execute_checkmodule:
  cmd.run:
    - name: checkmodule -M -m -o /root/systemdcontainerpolicy.mod /root/systemdcontainerpolicy.te
    - require:
      - file: copy_systemdcontainerpolicy_te

execute_semodule_package:
  cmd.run:
    - name: semodule_package -o /root/systemdcontainerpolicy.pp -m /root/systemdcontainerpolicy.mod
    - require:
      - cmd: execute_checkmodule

execute_semodule_install:
  cmd.run:
    - name: semodule -i /root/systemdcontainerpolicy.pp
    - require:
      - cmd: execute_semodule_package

{% endif %}

transfer_python_management_file:
  file.managed:
  - name: {{ python_helm_chart_path }}
  - source: salt://kubernetes_common/helm_chart.py
  - makedirs: true

update_oci_app_version:
  cmd.run:
    - name: python3 {{ python_helm_chart_path }} -o {{ helm_chart_url }}/{{ helm_chart_name }} --chart-file {{ self_signed_path }}/Chart.yaml {{ devel_flag }}
    {% if is_external_cluster %}
    - require:
      - pkg: install_external_kubernetes_dependencies
      - cmd: install_helm_on_controller
      - file: transfer_python_management_file
      - file: copy_chart_yaml_file
    {% endif %}

{% if grains.get('install_mlm_server') == true or is_external_cluster %}

build_helm_dependencies:
  cmd.run:
    - name: helm dependencies build
    - cwd: {{ self_signed_path }}
    {% if is_external_cluster %}
    - require:
      - cmd: update_oci_app_version
    {% endif %}

install_uyuni_on_kubernetes:
  cmd.run:
    - name: helm upgrade --install uyuni ./selfsigned -f ./selfsigned/values.yaml -n uyuni
    - cwd: {{ helm_chart_directory }}
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    {% if is_external_cluster %}
    - require:
      - cmd: build_helm_dependencies
      - file: copy_value_yaml_file
      - cmd: create_external_kubernetes_uyuni_namespace
    {% endif %}

save_script_to_get_pod_name:
  file.managed:
    - name: /usr/local/bin/get_server_pod_name
    - source: salt://server_kubernetes/get_server_pod_name
    - template: jinja
    - mode: 700
    - user: root
    - group: root

{% endif %}

{% endif %}

{% endif %}

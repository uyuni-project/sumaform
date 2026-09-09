{% set helm_chart_directory = "/root/helm-charts" %}
{% set values_yaml_path = helm_chart_directory ~ "/selfsigned/values.yaml" %}
{% set self_signed_path = helm_chart_directory ~ "/selfsigned" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set helm_chart_name = grains.get('helm_chart_name') %}
{% set helm_chart_url = grains.get('helm_chart_url') %}
{% set python_helm_chart_path = "/root/helm_chart.py" %}
{% set proxy_namespace = "uyuni" %}
{% set proxy_FQDN = grains.get("fqdn") %}
{% set server_FQDN = grains.get("server") %}
{% set proxy_name = "proxy-cert" %}
{% set proxy_cert_vars_file = "/etc/profile.d/proxy_certs_vars.sh" %}
{% set devel_flag = "--devel" if grains.get('use_devel_oci') else "" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}



setup_environmental_variables_in_proxy:
  file.managed:
    - name: {{ proxy_cert_vars_file }}
    - contents: |
        export PYTHON_HELM_CHART_PATH={{ python_helm_chart_path }}
        export HELM_CHART_DIRECTORY={{ helm_chart_directory }}
        export SELF_SIGNED_PATH={{ self_signed_path }}
        export VALUES_YAML_PATH={{ values_yaml_path }}
        export HELM_CHART_NAME={{ helm_chart_name }}
        export HELM_CHART_URL={{ helm_chart_url }}
        export PROXY_NAMESPACE={{ proxy_namespace }}
        export PROXY_NAME={{ proxy_name }}
        export PROXY_FQDN={{ proxy_FQDN }}
        export SERVER_FQDN={{ server_FQDN }}
        export DEVEL_FLAG={{ devel_flag }}

ssh_private_key_proxy_kubernetes:
  file.managed:
    - name: /root/.ssh/id_ed25519
    - source: salt://proxy_kubernetes/id_ed25519
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

ssh_public_key_proxy_kubernetes:
  file.managed:
    - name: /root/.ssh/id_ed25519.pub
    - source: salt://proxy_kubernetes/id_ed25519.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

authorized_keys_proxy_kubernetes:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://proxy_kubernetes/id_ed25519.pub
    - makedirs: True

authorized_keys_proxy_server:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://server_kubernetes/server_keys/id_ed25519_server_kubernetes.pub

ssh_private_key_proxy_kubernetes_for_server:
  file.managed:
    - name: /root/.ssh/id_ed25519_proxy
    - source: salt://proxy_kubernetes/proxy_keys/id_ed25519_proxy
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

ssh_public_key_proxy_kubernetes_server_exchange:
  file.managed:
    - name: /root/.ssh/id_ed25519_proxy.pub
    - source: salt://proxy_kubernetes/proxy_keys/id_ed25519_proxy.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

ssh_config_proxy_kubernetes:
  file.managed:
    - name: /root/.ssh/config
    - source: salt://proxy_kubernetes/config
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

copy_certs_generator:
  file.managed:
    - name: /root/proxy-gen-certs.yaml
    - source: salt://proxy_kubernetes/proxy-gen-certs.yaml
    - template: jinja
    - context:
        proxy_FQDN: {{ proxy_FQDN }}
        proxy_namespace: {{ proxy_namespace }}
        proxy_name: {{ proxy_name }}

apply_and_transfer_env_variables:
  cmd.run:
  - name: |
      scp {{ proxy_cert_vars_file }} {{ grains['server'] }}:{{ proxy_cert_vars_file }}
  - cwd: /root
  - require:
      - file: setup_environmental_variables_in_proxy
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

check_ssh_communication:
  cmd.run:
    - name: ssh-keyscan -H {{ grains['server'] }} >> ~/.ssh/known_hosts
    - require:
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

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
        cert_manager_namespace: {{ cert_manager_namespace }}
        container_registry: {{ grains.get("container_registry") }}

transfer_python_management_file:
  file.managed:
  - name: {{ python_helm_chart_path }}
  - source: salt://kubernetes_common/helm_chart.py
  - makedirs: true

copy_manifest_uyuni_ingress_proxy:
  file.managed:
    - name: /var/lib/rancher/rke2/server/manifests/uyuni-ingress-proxy.yaml
    - source: salt://proxy_kubernetes/uyuni-ingress-proxy.yaml
    - makedirs: True

{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}
{% if is_supported_os %}
{% set proxy_namespace = "uyuni" %}
{% set proxy_FQDN = grains.get("fqdn") %}
{% set server_FQDN = grains.get("server") %}
{% set proxy_name = "proxy-cert" %}
{% set proxy_cert_vars_file = "/etc/profile.d/proxy_certs_vars.sh" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}

{% set pkg_map = {
  'openSUSE Tumbleweed' : 'jq'
} %}

{% if osfullname in pkg_map %}
install_dependencies_proxy_node:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

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

setup_environmental_variables_in_proxy:
  file.managed:
    - name: {{ proxy_cert_vars_file }}
    - contents: |
        export PROXY_NAMESPACE={{ proxy_namespace }}
        export PROXY_NAME={{ proxy_name }}
        export PROXY_FQDN={{ proxy_FQDN }}
        export SERVER_FQDN={{ server_FQDN }}

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

#####################################################
################ Setup proxy certs ##################
#####################################################

{% if not is_slmicro_6_2 %}

create_uyuni_namespace_proxy:
  cmd.run:
  - name : kubectl create namespace {{ proxy_namespace }}
  - env:
      - KUBECONFIG: {{ kubeconfig }}

generate_configuration_certs_file_from_server:
  cmd.run:
    - name: |
       scp /root/proxy-gen-certs.yaml root@{{ grains['server'] }}:/root/proxy-gen-certs.yaml
       ssh {{ grains['server'] }} "kubectl apply -f /root/proxy-gen-certs.yaml"
    - cwd: /root
    - require:
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

key_exchange_between_clusters:
  cmd.run:
  - name: |
      source {{ proxy_cert_vars_file }}
      ssh {{ grains['server'] }} "kubectl get secret -n $PROXY_NAMESPACE -o yaml $PROXY_NAME" | \
        sed -e "s/name: $PROXY_NAME/name: proxy-cert/" \
        -e "s/namespace: $PROXY_NAMESPACE/namespace: $PROXY_NAMESPACE/" \
        -e "/\(uid\)\|\(resourceVersion\)\|\(creationTimestamp\)\|\(cert-manager\)/d" | \
        kubectl apply -f -
  - cwd: /root
  - env:
      - KUBECONFIG: {{ kubeconfig }}
  - require:
      - cmd: apply_and_transfer_env_variables
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

generate_proxy_config_file:
  cmd.run:
  - name: |
      ssh {{ grains['server'] }} "kubectl get secret \$PROXY_NAME -n \$PROXY_NAMESPACE -o jsonpath=\"{.data['ca\\.crt']}\" | base64 -d > /root/ca.crt"
      ssh {{ grains['server'] }} "kubectl cp /root/ca.crt \$PROXY_NAMESPACE/\$(get_server_pod_name):/ca.crt"
      ssh {{ grains['server'] }} "kubectl get secret \$PROXY_NAME -n \$PROXY_NAMESPACE  -o jsonpath=\"{.data['tls\\.crt']}\" | base64 -d > /root/tls.crt"
      ssh {{ grains['server'] }} "kubectl cp /root/tls.crt \$PROXY_NAMESPACE/\$(get_server_pod_name):/tls.crt"
      ssh {{ grains['server'] }} "kubectl get secret \$PROXY_NAME -n \$PROXY_NAMESPACE  -o jsonpath=\"{.data['tls\\.key']}\" | base64 -d > /root/tls.key"
      ssh {{ grains['server'] }} "kubectl cp /root/tls.key \$PROXY_NAMESPACE/\$(get_server_pod_name):/tls.key"
      ssh {{ grains['server'] }} "kubectl exec \$(get_server_pod_name) -n \$PROXY_NAMESPACE --  spacecmd -u admin -p admin proxy_container_config -- \$PROXY_FQDN {{ grains['server'] }} 2048 galaxy-noise@suse.com ca.crt tls.crt tls.key"
      ssh {{ grains['server'] }} "kubectl cp \$PROXY_NAMESPACE/\$(get_server_pod_name):/config.tar.gz /root/config.tar.gz"
      scp {{ grains['server'] }}:/root/config.tar.gz /root/config.tar.gz
  - cwd: /root
  - env:
      - KUBECONFIG: {{ kubeconfig }}
  - require:
      - cmd: apply_and_transfer_env_variables
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

copy_uyuni_ca:
  cmd.run:
  - name: |
      source {{ proxy_cert_vars_file }}
      ssh {{ grains['server'] }} "kubectl get cm -n $PROXY_NAMESPACE uyuni-ca -o \"jsonpath={.data.ca\\.crt}\" >root-ca.crt"
      scp {{ grains['server'] }}:root-ca.crt root-ca.crt
      kubectl create configmap uyuni-ca -n $PROXY_NAMESPACE --from-file=ca.crt=root-ca.crt
  - cwd: /root
  - env:
      - KUBECONFIG: {{ kubeconfig }}
  - require:
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

{% endif %}

{% endif %}

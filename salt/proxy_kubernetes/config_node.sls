{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu', 'openSUSE Tumbleweed', 'SLES'] %}
{% set Namespace = "uyuni" %}
{% set ProxyFQDN = grains.get("fqdn") %}
{% set ProxyName = "proxy-cert" %}
{% set ProxyCertVarsFile = "/etc/profile.d/proxy_certs_vars.sh" %}
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

create_uyuni_namespace_proxy:
  cmd.run:
  - name : kubectl create namespace {{ Namespace }}
  - env:
    - KUBECONFIG: {{ kubeconfig }}

#####################################################
################ Setup proxy certs ##################
#####################################################

setup_enviornmental_variables_in_proxy:
  file.managed:
    - name: {{ ProxyCertVarsFile }}
    - contents: |
        export Namespace={{ Namespace }}
        export ProxyName={{ ProxyName }}


copy_certs_generator:
  file.managed:
    - name: /root/proxy-gen-certs.yaml
    - source: salt://proxy_kubernetes/proxy-gen-certs.yaml
    - template: jinja
    - context:
      ProxyFQDN: {{ ProxyFQDN }}
      Namespace: {{ Namespace }}
      ProxyName: {{ ProxyName }}

check_ssh_communication:
  cmd.run:
    - name: ssh-keyscan -H {{ grains['server'] }} >> ~/.ssh/known_hosts
    - require:
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

generate_configuration_certs_file_from_server:
  cmd.run:
    - name: |
       scp /root/proxy-gen-certs.yaml root@{{ grains['server'] }}:/root/proxy-gen-certs.yaml
       ssh {{ grains['server'] }} "kubectl apply -f /root/proxy-gen-certs.yaml"
    - cwd: /root
    - require:
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

apply_and_transfer_env_variables:
  cmd.run:
  - name: |
      scp {{ ProxyCertVarsFile }} {{ grains['server'] }}:{{ ProxyCertVarsFile }}
  - cwd: /root
  - require:
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

key_exchange_between_clusters:
  cmd.run:
  - name: |
      source {{ ProxyCertVarsFile }}
      ssh {{ grains['server'] }} "kubectl get secret -n $Namespace -o yaml $ProxyName" | \
        sed -e "s/name: $ProxyName/name: proxy-cert/" \
        -e "s/namespace: $Namespace/namespace: $Namespace/" \
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
      ssh {{ grains['server'] }} "kubectl get secret \$ProxyName -n \$Namespace -o jsonpath=\"{.data['ca\\.crt']}\" | base64 -d > /root/ca.crt"
      ssh {{ grains['server'] }} "kubectl cp /root/ca.crt \$Namespace/\$Server_pod:/ca.crt"
      ssh {{ grains['server'] }} "kubectl get secret \$ProxyName -n $Namespace  -o jsonpath=\"{.data['tls\\.crt']}\" | base64 -d > /root/tls.crt"
      ssh {{ grains['server'] }} "kubectl cp /root/tls.crt \$Namespace/\$Server_pod:/tls.crt"
      ssh {{ grains['server'] }} "kubectl get secret \$ProxyName -n \$Namespace  -o jsonpath=\"{.data['tls\\.key']}\" | base64 -d > /root/tls.key"
      ssh {{ grains['server'] }} "kubectl cp /root/tls.key \$Namespace/\$Server_pod:/tls.key"
      ssh {{ grains['server'] }} "kubectl exec \$Server_pod -n \$Namespace --  spacecmd -u admin -p admin proxy_container_config -- {{ ProxyFQDN }} {{ grains['server'] }} 2048 galaxy-noise@suse.com ca.crt tls.crt tls.key"
      ssh {{ grains['server'] }} "kubectl cp \$Namespace/\$Server_pod:/config.tar.gz /root/config.tar.gz"
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
      source {{ ProxyCertVarsFile }}
      ssh {{ grains['server'] }} "kubectl get cm -n $Namespace uyuni-ca -o \"jsonpath={.data.ca\\.crt}\" >root-ca.crt"
      scp {{ grains['server'] }}:root-ca.crt root-ca.crt
      kubectl create configmap uyuni-ca -n $Namespace --from-file=ca.crt=root-ca.crt
  - cwd: /root
  - env:
    - KUBECONFIG: {{ kubeconfig }}
  - require:
      - file: ssh_private_key_proxy_kubernetes_for_server
      - file: ssh_config_proxy_kubernetes

{% endif %}

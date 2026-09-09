{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set rke2_version = "v1.35.4+rke2r1" %}
{% set is_external_cluster = grains.get('install_kubernetes_server_on_external_cluster') == true %}
{% set kubeconfig = "/root/.kube/config" if is_external_cluster else "/etc/rancher/rke2/rke2.yaml" %}
{% set cert_manager_version = "v1.19.2" %}
{% set cert_manager_namespace = "cert-manager" %}
{% set traefik_file = "/root/kubernetes-crd-definition-v1.yml" %}
{% set local_path_storage_file = "/root/local-path-storage.yaml" %}
{% set local_path_namespace = "local-path-storage" %}
{% set scc_slmicro_pass = grains.get('scc_slmicro_pass') %}
{% set storage_class = grains.get('kubernetes_storage_class') | default('local-path', true) %}
{% set local_path = grains.get('local_path_provisioner_path') | default('/opt/local-path-provisioner', true) %}
{% set default_class = grains.get('local_path_provisioner_default_class', true) %}

{% set pkg_map = {
  'openSUSE Tumbleweed' : ['jq', 'checkpolicy', 'policycoreutils', 'container-selinux', 'openssl', 'git'],
  'Ubuntu': ['python3-yaml']
} %}

{% if osfullname in pkg_map %}
install_dependencies:
  pkg.latest:
    - pkgs: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

{% if is_slmicro_6_2 and scc_slmicro_pass %}
register_to_scc:
  cmd.run:
    - name: transactional-update register -r {{ scc_slmicro_pass }}

apply_transition_scc:
  cmd.run:
    - name: transactional-update apply
    - require:
      - cmd: register_to_scc
{% endif %}

tls-san_setup_file:
  file.managed:
    - name: /etc/rancher/rke2/config.yaml
    - contents: |
        tls-san:
          - "{{ grains.get("fqdn") }}"
        ingress-controller: traefik
        {% if is_tumbleweed or is_slmicro_6_2 %}
        selinux: true
        kubelet-arg:
          - "seccomp-default=true"
        {% endif %}
    - makedirs: True

copy_local-path-storage_installation_file:
  file.managed:
    - name: {{ local_path_storage_file }}
    - source: salt://kubernetes_common/local-path-storage.yaml
    - template: jinja
    - makedirs: true

copy_traefik_installation_file:
  file.managed:
  - name: {{ traefik_file }}
  - source: salt://kubernetes_common/kubernetes-crd-definition-v1.yml
  - makedirs: true


variables_rke2:
  file.managed:
    - name: /etc/profile.d/rke2_vars.sh
    - contents: |
        export PATH=$PATH:/opt/rke2/bin
        export KUBECONFIG={{ kubeconfig }}
        export RKE2_VERSION={{ rke2_version }}
        export CERT_MANAGER_VERSION={{ cert_manager_version }}
        export CERT_MANAGER_NAMESPACE={{ cert_manager_namespace }}
        export TRAEFIK_FILE={{ traefik_file }}
        export LOCAL_PATH_PROVISIONER_PATH={{ local_path_storage_file }}
        export LOCAL_PATH_PROVISIONER_STORAGE_CLASS={{ storage_class }}
        export LOCAL_PATH={{ local_path }}
        export LOCAL_PATH_NAMESPACE={{ local_path_namespace }}
        {% if is_slmicro_6_2 %}
        export RKE2_INSTALL_METHOD=rpm
        {% else %}
        export RKE2_INSTALL_METHOD=tar
        {% endif %}

{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}
{% if is_supported_os %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set pkg_map = {} %}

{% if osfullname in pkg_map %}
install_dependencies_helm_provisioner:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

copy_local-path-storage_installation_file:
  file.managed:
  - name: /root/local-path-storage.yaml
  - source: salt://kubernetes_common/local-path-storage.yaml
  - makedirs: true

install_local_path_provisioner:
  cmd.run:
    - name: kubectl apply -f /root/local-path-storage.yaml
    - env:
      - KUBECONFIG: {{ kubeconfig }}

set_local-path-storage-file-as-default:
  cmd.run:
    - name: |
        kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    - env:
      - KUBECONFIG: {{ kubeconfig }}

{% if is_tumbleweed or is_slmicro_6_2 %}

create_local-path-provisioner_directory:
  file.directory:
    - name: /opt/local-path-provisioner

set_local-path-provisioner_selinux_tags:
  cmd.run:
    - name: restorecon -R -v /opt/local-path-provisioner
    - require:
      - file: create_local-path-provisioner_directory
    - env:
      - KUBECONFIG: {{ kubeconfig }}


restart_local-path-provisioner_pods:
  cmd.run:
    - name: kubectl delete pods --all -n local-path-storage
    - require:
      - cmd: set_local-path-provisioner_selinux_tags
      - file: create_local-path-provisioner_directory
    - env:
      - KUBECONFIG: {{ kubeconfig }}

{% endif %}

{% endif %}

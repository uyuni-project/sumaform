{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}
{% if is_supported_os %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set storage_class = grains.get('kubernetes_storage_class') or 'local-path' %}
{% set local_path = grains.get('local_path_provisioner_path') or '/opt/local-path-provisioner' %}
{% set default_class = grains.get('local_path_provisioner_default_class', true) %}
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
  - template: jinja
  - makedirs: true

install_local_path_provisioner:
  cmd.run:
    - name: kubectl apply -f /root/local-path-storage.yaml
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - file: copy_local-path-storage_installation_file

{% if default_class %}
set_local-path-storage-file-as-default:
  cmd.run:
    - name: |
        kubectl patch storageclass {{ storage_class }} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_local_path_provisioner
{% endif %}

{% if is_tumbleweed or is_slmicro_6_2 %}

create_local-path-provisioner_directory:
  file.directory:
    - name: {{ local_path }}

set_local-path-provisioner_selinux_tags:
  cmd.run:
    - name: restorecon -R -v {{ local_path }}
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

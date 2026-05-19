{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}
{% if is_supported_os %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set nfs_server = grains.get('nfs_storage_server') %}
{% set nfs_path = grains.get('nfs_storage_path') %}
{% set pkg_map = {
    'SLES': ['nfs-client'],
    'SL-Micro': ['nfs-client'],
    'openSUSE Tumbleweed': ['nfs-client'],
    'Ubuntu': ['nfs-common']
} %}

{% if not nfs_server or not nfs_path %}
missing_nfs_storage_configuration:
  test.fail_without_changes:
    - name: nfs_storage_server and nfs_storage_path must be set when install_nfs_provisioner is true
{% else %}

install_nfs_client_package:
  pkg.latest:
    - pkgs: {{ pkg_map.get(osfullname) }}
    - refresh: True

copy_nfs_storage_installation_file:
  file.managed:
  - name: /root/nfs-storage.yaml
  - source: salt://kubernetes_common/nfs-storage.yaml
  - template: jinja
  - makedirs: true

install_nfs_provisioner:
  cmd.run:
    - name: kubectl apply -f /root/nfs-storage.yaml
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - pkg: install_nfs_client_package
      - file: copy_nfs_storage_installation_file

{% if grains.get('nfs_provisioner_default_class', false) %}
set_nfs-storage-file-as-default:
  cmd.run:
    - name: |
        kubectl patch storageclass {{ grains.get('kubernetes_storage_class') or 'nfs-client' }} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: install_nfs_provisioner
{% endif %}

{% endif %}

{% endif %}

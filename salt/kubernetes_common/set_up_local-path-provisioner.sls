{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu'] %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set pkg_map = {
    'Ubuntu': ''
} %}

{% if pkg_map.get(osfullname) != '' %}
install_dependencies_helm:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

copy_local-path-storage_installation_file:
  file.managed:
  - name: /root/local-path-storage.yaml
  - source: salt://kubernetes/local-path-storage.yaml
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

{% endif %}

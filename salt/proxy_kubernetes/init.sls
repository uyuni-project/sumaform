{% set storage_backend = grains.get('kubernetes_storage_backend', 'local-path') %}
include:
  - repos
  - kubernetes_common.install_rke2
  - kubernetes_common.install_helm
  - proxy_kubernetes.config_node
  {% if grains.get('install_local_path_provisioner') == true and storage_backend == 'local-path' %}
  - kubernetes_common.set_up_local-path-provisioner
  {% endif %}
  {% if grains.get('install_traefik') == true %}
  - kubernetes_common.install_traefik
  {% endif %}
  - proxy_kubernetes.install_kubernetes_proxy

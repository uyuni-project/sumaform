{% set storage_backend = grains.get('kubernetes_storage_backend', 'local-path') %}

include:
  - repos
  {% if grains.get('install_rke2') == true %}
  - kubernetes_common.install_rke2
  - proxy_kubernetes.config_node
  {% endif %}
  {% if grains.get('install_helm') == true %}
  - kubernetes_common.install_helm
  {% endif %}
  {% if grains.get('install_local_path_provisioner') == true and storage_backend == 'local-path' %}
  - kubernetes_common.set_up_local-path-provisioner
  {% endif %}
  {% if grains.get('install_traefik') == true %}
  - kubernetes_common.install_traefik
  {% endif %}
  - proxy_kubernetes.install_kubernetes_proxy

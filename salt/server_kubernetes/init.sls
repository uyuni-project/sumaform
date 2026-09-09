{% set storage_backend = grains.get('kubernetes_storage_backend', 'local-path') %}

include:
  - repos
  - server_kubernetes.additional_disk
  - kubernetes_common.kubernetes_dependencies
  - server_kubernetes.install_kubernetes_server

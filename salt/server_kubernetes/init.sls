include:
  - repos
  - kubernetes_common.install_rke2
  - kubernetes_common.install_helm
  - server_kubernetes.set-persistent-volumes
  {% if grains.get('install_local_path_provisioner') == true %}
  - kubernetes_common.set_up_local-path-provisioner
  {% endif %}
  {% if grains.get('install_traefik') == true %}
  - kubernetes_common.install_traefik
  {% endif %}
  - server_kubernetes.install_kubernetes_server
  # The installation of the server is in a different
  #  sls because in the future maybe we want to execute 
  #  the whole secondary stage. And at that point we just
  #  have to put the states not related to the installation
  #  by itself of the common podman version here. 

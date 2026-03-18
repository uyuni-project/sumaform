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

ssh_config_proxy_kubernetes:
  file.managed:
    - name: /root/.ssh/config
    - source: salt://proxy_kubernetes/config
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

include:
  - kubernetes_common.install_rke2
  - kubernetes_common.install_helm
  {% if grains.get('install_local_path_provisioner') == true %}
  - kubernetes_common.set_up_local-path-provisioner
  {% endif %}
  {% if grains.get('install_traefik') == true %}
  - kubernetes_common.install_traefik
  {% endif %}
  {% if grains.get('install_mlm_proxy') == true %}
  - proxy_kubernetes.install_kubernetes_proxy
  {% endif %}

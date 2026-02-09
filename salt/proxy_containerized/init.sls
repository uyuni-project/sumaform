ssh_private_key_proxy_containerized:
  file.managed:
    - name: /root/.ssh/id_ed25519
    - source: salt://proxy_containerized/id_ed25519
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

ssh_public_key_proxy_containerized:
  file.managed:
    - name: /root/.ssh/id_ed25519.pub
    - source: salt://proxy_containerized/id_ed25519.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

authorized_keys_proxy_containerized:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://proxy_containerized/id_ed25519.pub
    - makedirs: True

ssh_config_proxy_containerized:
  file.managed:
    - name: /root/.ssh/config
    - source: salt://proxy_containerized/config
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

{% set runtime = grains.get('container_runtime') | default('podman', true) %}
include:
  - repos
  {% if runtime == 'rke2'%}
  - kubernetes.install_rke2
  - kubernetes.install_helm
  - kubernetes.set_up_local-path-provisioner
  - proxy_containerized.install_kubernetes_proxy
  {% else %}
  {% if runtime == 'k3s'%}
  - proxy_containerized.install_k3s
  {% endif %}
  - proxy_containerized.install_mgrpxy
  {% endif %}


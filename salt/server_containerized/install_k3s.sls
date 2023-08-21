include:
  - server_containerized.install_common

k3s_install:
  cmd.run:
    - name: curl -sfL https://get.k3s.io | sh -
    - env:
      - INSTALL_K3S_EXEC: "--tls-san={{ grains.get('fqdn') }}" 
    - unless: systemctl is-active k3s

k3s_traefik_config:
  file.managed:
    - name: /var/lib/rancher/k3s/server/manifests/k3s-traefik-config.yaml
    - source: salt://server_containerized/k3s-traefik-config.yaml
    - makedirs: true

helm_install:
  pkg.installed:
    - refresh: True
    - name: helm

chart_values_file:
  file.managed:
    - name: /root/chart-values.yaml
    - source: salt://server_containerized/chart-values.yaml
    - template: jinja

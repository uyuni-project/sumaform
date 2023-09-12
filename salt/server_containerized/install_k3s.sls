include:
  - server_containerized.install_common

k3s_install:
  cmd.run:
    - name: curl -sfL https://get.k3s.io | sh -
    - env:
      - INSTALL_K3S_EXEC: "--tls-san={{ grains.get('fqdn') }}" 
    - unless: systemctl is-active k3s

helm_install:
  pkg.installed:
    - refresh: True
    - name: helm

chart_values_file:
  file.managed:
    - name: /root/chart-values.yaml
    - source: salt://server_containerized/chart-values.yaml
    - template: jinja

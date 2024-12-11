include:
  - server_containerized.install_common

{% if grains['osfullname'] not in ['SLE Micro', 'openSUSE Leap Micro'] %}
k3s_install:
  cmd.run:
    - name: curl -sfL https://get.k3s.io | sh -
    - env:
      - INSTALL_K3S_EXEC: "--tls-san={{ grains.get('fqdn') }}" 
    - unless: systemctl is-active k3s

wait_for_traefik:
  cmd.script:
    - name: salt://server_containerized/wait_for_kube_resource.py
    - args: kube-system deploy traefik
    - use_vt: True
    - template: jinja
    - require:
      - cmd: k3s_install

helm_install:
  pkg.installed:
    - refresh: True
    - name: helm
{% endif %}

{%- set mirror_hostname = grains.get('server_mounted_mirror') if grains.get('server_mounted_mirror') else grains.get('mirror') %}
{% if mirror_hostname %}
mirror_pv_file:
  file.managed:
    - name: /root/mirror-pv.yaml
    - source: salt://server_containerized/mirror-pv.yaml
    - template: jinja

mirror_pv_deploy:
  cmd.run:
    - name: kubectl apply -f /root/mirror-pv.yaml
    - unless: kubectl get pv mirror
    - require:
      - file: mirror_pv_file
{% endif %}

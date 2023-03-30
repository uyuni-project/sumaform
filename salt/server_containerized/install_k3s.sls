{% from 'server_containerized/macros.sls' import run_in_container with context %}

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

cert_manager_install:
  cmd.run:
    - name: kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
    - unless: kubectl get deployment -n cert-manager | grep cert-manager

wait_cert_manager_ready:
  cmd.script:
    - name: salt://server_containerized/wait_for_kube_resource.py
    - args: cert-manager deployment cert-manager-webhook
    - use_vt: True
    - template: jinja
    - require:
      - cmd: cert_manager_install

ca_issuer_file:
  file.managed:
    - name: /root/cert-manager-issuer.yaml
    - source: salt://server_containerized/cert-manager-selfsigned-issuer.yaml
    - template: jinja

ca_issuer:
  cmd.run:
    - name: kubectl apply -f /root/cert-manager-issuer.yaml
    - unless: kubectl get issuer | grep uyuni-ca-issuer
    - require:
      - file: ca_issuer_file
      - cmd: wait_cert_manager_ready

wait_issuer_ready:
  cmd.script:
    - name: salt://server_containerized/wait_for_kube_resource.py
    - args: default issuer uyuni-ca-issuer
    - use_vt: True
    - template: jinja
    - require:
      - cmd: ca_issuer

get_ca:
  cmd.run:
    - name: kubectl get secret uyuni-ca -o=jsonpath='{.data.ca\.crt}' | base64 -d > /root/ca.crt
    - creates: /root/ca.crt
    - require:
      - cmd: wait_issuer_ready

ca_configmap_file:
  cmd.run:
    - name: kubectl create configmap uyuni-ca --from-file=/root/ca.crt --dry-run=client -o yaml >/root/uyuni-ca.yaml
    - creates: /root/uyuni-ca.yaml
    - require:
      - cmd:  get_ca

ca_configmap:
  cmd.run:
    - name: kubectl apply -f /root/uyuni-ca.yaml
    - require:
      - cmd: ca_configmap_file

chart_values_file:
  file.managed:
    - name: /root/chart-values.yaml
    - source: salt://server_containerized/chart-values.yaml
    - template: jinja

chart_install:
  cmd.run:
    - name: helm upgrade --install uyuni oci://registry.opensuse.org/systemsmanagement/uyuni/master/servercontainer/charts/uyuni/server -f /root/chart-values.yaml
    - env:
      - KUBECONFIG: /etc/rancher/k3s/k3s.yaml
    - unless: helm --kubeconfig /etc/rancher/k3s/k3s.yaml list | grep uyuni
    - require:
      - file: chart_values_file
      - cmd: ca_configmap

wait_pod_running:
  cmd.script:
    - name: salt://server_containerized/wait_for_kube_resource.py
    - args: default pod -lapp=uyuni 
    - use_vt: True
    - template: jinja
    - require:
      - cmd: chart_install

wait_for_setup_end:
  cmd.script:
    - name: salt://server_containerized/wait_for_setup_end.py
    - args: {{ grains.get('container_runtime') }}
    - use_vt: True
    - template: jinja
    - require:
      - cmd: wait_pod_running

spacecmd_config:
  cmd.run:
    - name: {{ run_in_container("sh -c 'mkdir -p /root/.spacecmd; echo -e \"[spacecmd]\\nserver={}\" >/root/.spacecmd/config'".format(grains.get('fqdn'))) }}
    - mkdirs: true
    - contents: |
        [spacecmd]
        server={{ grains.get('fqdn') }}

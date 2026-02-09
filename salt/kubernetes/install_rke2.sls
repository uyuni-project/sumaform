{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu'] %}
{% set rke2_version = "v1.34.2+rke2r1" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set pkg_map = {
    'Ubuntu': ''
} %}

tls-san_setup_file:
  file.managed:
    - name: /etc/rancher/rke2/config.yaml
    - contents: |
        tls-san:
          - "{{ grains.get("fqdn") }}"
    - makedirs: True

{% if pkg_map.get(osfullname) != '' %}
install_dependencies:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

rke2_install:
  cmd.run:
    - name: curl -sfL https://get.rke2.io | sh -
    - env:
      - INSTALL_RKE2_VERSION: "{{ rke2_version }}"
    - unless: systemctl is-active rke2-server

rke2_server_start_and_enable:
  service.running:
    - name: rke2-server
    - enable: True

link_kubectl_rke2:
  file.symlink:
    - name: /usr/local/bin/kubectl
    - target: /var/lib/rancher/rke2/bin/kubectl
    - force: True
    - makedirs: True

link_crictl_rke2:
  file.symlink:
    - name: /usr/local/bin/crictl
    - target: /var/lib/rancher/rke2/bin/crictl
    - force: True
    - makedirs: True

link_ctr_rke2:
  file.symlink:
    - name: /usr/local/bin/ctr
    - target: /var/lib/rancher/rke2/bin/ctr
    - force: True
    - makedirs: True

variables_rke2:
  file.managed:
    - name: /etc/profile.d/rke2_vars.sh
    - contents: |
        export PATH=$PATH:/opt/rke2/bin
        export KUBECONFIG={{ kubeconfig }}


{% endif %}


{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_slmicro_6_2 = osfullname == 'SL-Micro' and osrelease == '6.2' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_slmicro_6_2 or is_ubuntu or is_tumbleweed %}
{% if is_supported_os %}
{% set rke2_version = "v1.35.6+rke2r1" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}

{% set pkg_map = {
  'openSUSE Tumbleweed' : ['checkpolicy', 'policycoreutils', 'container-selinux']
} %}

{% if osfullname in pkg_map %}
install_dependencies:
  pkg.latest:
    - pkgs: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

{% if is_slmicro_6_2 and grains.get('scc_slmicro_pass') %}
register_to_scc:
  cmd.run:
    - name: transactional-update register -r {{ grains.get('scc_slmicro_pass') }}

apply_transition_scc:
  cmd.run:
    - name: transactional-update apply
    - require:
      - cmd: register_to_scc
{% endif %}

tls-san_setup_file:
  file.managed:
    - name: /etc/rancher/rke2/config.yaml
    - contents: |
        tls-san:
          - "{{ grains.get("fqdn") }}"
        ingress-controller: traefik
        {% if is_tumbleweed or is_slmicro_6_2 %}
        selinux: true
        kubelet-arg:
          - "seccomp-default=true"
        {% endif %}
    - makedirs: True

rke2_config_file_exists:
  file.exists:
    - name: /etc/rancher/rke2/config.yaml
    - require:
      - file: tls-san_setup_file


rke2_install:
  cmd.run:
    - name: curl -sfL https://get.rke2.io | sh -
    - env:
      - INSTALL_RKE2_VERSION: "{{ rke2_version }}"
      {% if is_slmicro_6_2 %}
      - INSTALL_RKE2_METHOD: rpm
      - INSTALL_RKE2_SELINUX: true
      {% endif %}
    - require:
      - file: rke2_config_file_exists
    - unless: systemctl is-active rke2-server
    {% if is_slmicro_6_2  and grains.get('scc_slmicro_pass') %} 
    - require:
      - cmd: register_to_scc
      - cmd: apply_transition_scc
    {% endif %}

{% if is_slmicro_6_2 %}
apply_transition_rke2:
  cmd.run:
    - name: transactional-update apply
    - require:
      - cmd: rke2_install
{% endif %}

rke2_wait_for_service_unit:
  cmd.run:
    - name: timeout 300 bash -c 'until systemctl list-unit-files | grep -q "^rke2-server.service"; do sleep 5; done'
    - require:
      {% if is_slmicro_6_2 %}
      - cmd: apply_transition_rke2
      {% else %}
      - cmd: rke2_install
      {% endif %}

rke2_server_enable:
  service.enabled:
    - name: rke2-server
    - require:
      {% if is_slmicro_6_2 %}
      - cmd: apply_transition_rke2
      {% endif %}
      - cmd: rke2_wait_for_service_unit
      - file: tls-san_setup_file
      {% if is_slmicro_6_2 and grains.get('scc_slmicro_pass') %}
      - cmd: register_to_scc
      - cmd: apply_transition_scc
      {% endif %}

{% if is_tumbleweed %}
rke2_selinux_install:
  pkg.installed:
    - name: rke2-selinux
{% endif %}

rke2_server_start:
  service.running:
    - name: rke2-server
    - require:
      - service: rke2_server_enable
      {% if is_tumbleweed %}
      - pkg: rke2_selinux_install
      {% endif %}

rke2_server_wait_until_active:
  cmd.run:
    - name: timeout 300 bash -c 'until systemctl is-active --quiet rke2-server; do sleep 5; done'
    - require:
      - service: rke2_server_start

link_kubectl_rke2:
  file.symlink:
    - name: /usr/local/bin/kubectl
    - target: /var/lib/rancher/rke2/bin/kubectl
    - force: True
    - makedirs: True
    - require:
      - cmd: rke2_server_wait_until_active

link_crictl_rke2:
  file.symlink:
    - name: /usr/local/bin/crictl
    - target: /var/lib/rancher/rke2/bin/crictl
    - force: True
    - makedirs: True
    - require:
      - cmd: rke2_server_wait_until_active

link_ctr_rke2:
  file.symlink:
    - name: /usr/local/bin/ctr
    - target: /var/lib/rancher/rke2/bin/ctr
    - force: True
    - makedirs: True
    - require:
      - cmd: rke2_server_wait_until_active

variables_rke2:
  file.managed:
    - name: /etc/profile.d/rke2_vars.sh
    - contents: |
        export PATH=$PATH:/opt/rke2/bin
        export KUBECONFIG={{ kubeconfig }}


{% endif %}


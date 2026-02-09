{% set osfullname = grains['osfullname'] %}
{% if osfullname in ['Ubuntu'] %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set rke2_namespace = "kube-system" %}
{% set cert_manager_version = "v1.19.2" %}
{% set cert_manager_namespace = "cert-manager" %}

{% set pkg_map = {
    'Ubuntu': ''
} %}

{% if pkg_map.get(osfullname) != '' %}
install_dependencies_helm:
  pkg.latest:
    - name: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

h

##### The proxy helm is not ready, once that Hexagon submits a way to install it the rest of the sls will be added.
{% endif %}


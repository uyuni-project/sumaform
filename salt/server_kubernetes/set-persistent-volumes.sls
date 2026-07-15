{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}
{% set storage_backend = grains.get('kubernetes_storage_backend', 'local-path') %}
{% set create_static_var_spacewalk_pv = grains.get('kubernetes_create_static_var_spacewalk_pv') %}
{% set create_static_var_pgsql_pv = grains.get('kubernetes_create_static_var_pgsql_pv') %}
{% if create_static_var_spacewalk_pv is none %}
{% set create_static_var_spacewalk_pv = storage_backend == 'local-path' %}
{% endif %}
{% if create_static_var_pgsql_pv is none %}
{% set create_static_var_pgsql_pv = storage_backend == 'local-path' %}
{% endif %}

create_uyuni_namespace:
  cmd.run:
  - name: kubectl create namespace uyuni
  - env:
    - KUBECONFIG: {{ kubeconfig }}
  - unless: KUBECONFIG={{ kubeconfig }} kubectl get namespace uyuni

{% if create_static_var_spacewalk_pv %}
copy_var_spacewalk_file:
  file.managed:
    - name: /root/volume-configuration-var-spacewalk.yml
    - source: salt://server_kubernetes/volume-configuration-var-spacewalk.yml
    - template: jinja

apply_var_spacewalk_file:
  cmd.run:
    - name: kubectl apply -f /root/volume-configuration-var-spacewalk.yml
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: create_uyuni_namespace
      - file: copy_var_spacewalk_file
{% endif %}

{% if create_static_var_pgsql_pv %}
copy_var_pgsql_file:
  file.managed:
    - name: /root/volume-configuration-var-pgsql.yml
    - source: salt://server_kubernetes/volume-configuration-var-pgsql.yml
    - template: jinja

apply_var_pgsql_file:
  cmd.run:
    - name: kubectl apply -f /root/volume-configuration-var-pgsql.yml
    - env:
      - KUBECONFIG: {{ kubeconfig }}
    - require:
      - cmd: create_uyuni_namespace
      - file: copy_var_pgsql_file
{% endif %}

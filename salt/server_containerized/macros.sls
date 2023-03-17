{% macro run_in_container(cmd) -%}
{%- if grains.get('container_runtime') == "podman" -%}
  podman exec uyuni-server {{ cmd }}
{%- elif grains.get('container_runtime') == "k3s" -%}
  kubectl exec $(kubectl get pod -lapp=uyuni -o jsonpath={.items[0].metadata.name}) -- {{ cmd }}
{%- endif -%}
{%- endmacro %}

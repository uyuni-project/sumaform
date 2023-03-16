{% macro run_in_container(cmd) -%}
  podman exec uyuni-server {{ cmd }}
{%- endmacro %}

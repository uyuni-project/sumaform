{# Collection of macros to simplify SLS files #}

{# Build repository url for a SLE 15 Module.

Args:
  module: name of SLE 15 module. If the name consists of multiple words,
    they should be separated by an underscore. Names in UPPERCASE are kept as they are.
    Examples: development_tools, containers, HPC
  default_mirror: mirror to use when no mirror is configured via grains
  product: boolean to indicate "product" or "updates" repository
#}
{% macro sle15_module_repourl(module, default_mirror, product) -%}
{# REVIEW: why is |default needed? -#}
{% set mirror = grains.get("mirror")|default(default_mirror, true) -%}
{% if product -%}
{% set suse_base_path = "SUSE/" ~ "Products" -%}
{% else -%}
{% set suse_base_path = "SUSE/" ~ "Updates" -%}
{% endif -%}
{% set sle_version = "15" if grains["osrelease"] == 15 else "15-SP" ~ grains["osrelease_info"][1] -%}
{% set repo_path = "product" if product else "update" -%}
{% if module is upper -%}
{% set sle_module = "SLE-Module-" ~ module -%}
{% else -%}
{% set sle_module = "SLE-Module-" ~ module.split("_")|map("capitalize")|join("-") -%}
{% endif -%}
http://{{mirror}}/{{suse_base_path}}/{{sle_module}}/{{sle_version}}/x86_64/{{repo_path}}/
{%- endmacro %}

{# SLE 15 Module repositories block.

Includes two repositories, one for "pool" and one for "updates".
Args:
  module: name of SLE 15 module. If the name consists of multiple words,
    they should be separated by an underscore. Example: development_tools
  default_mirror: mirror to use when no mirror is configured via grains
#}
{% macro sle15_module_repos(module, default_mirror) -%}
{{module}}_repo_pool:
  pkgrepo.managed:
    - baseurl: {{ sle15_module_repourl(module, default_mirror, True) }}
    - refresh: true

{{module}}_repo_updates:
  pkgrepo.managed:
    - baseurl: {{ sle15_module_repourl(module, default_mirror, False) }}
    - refresh: true
{% endmacro -%}

{% from "salt_testenv/lib.sls" import sle15_module_repos with context -%}

{% if grains["os"] != "SUSE" -%}
  {{ raise("Incompatible OS, this state only works on openSUSE/SUSE distributions.")}}
{% endif  -%}

## Repos

{# SLE 15 -#}
{% if grains["osfullname"] == "SLES" -%}
{# hpc is needed for libhttp_parser_2_7_1, required by libgit2 -#}
{% for module in ["development_tools", "HPC", "containers" ] -%}
{{ sle15_module_repos(module, "dist.nue.suse.com/ibs") }}
{% endfor -%}
{% if grains["osrelease_info"][1]|int >= 6 -%}
{% for module in ["python3", "systems_management"] -%}
{{ sle15_module_repos(module, "dist.nue.suse.com/ibs") }}
{% endfor -%}
{% endif -%}

{% if grains["osrelease"] == 15 -%}
  {% set repo_path = "15" -%}
{% else -%}
  {% if grains["osrelease_info"][1]|int >= 3 -%}
  {% set repo_path = "15." ~ grains["osrelease_info"][1] -%}
  {% else -%}
  {% set repo_path = "15-SP" ~ grains["osrelease_info"][1] -%}
  {% endif -%}
{% endif -%}

{#- Leap -#}
{%- elif grains["osfullname"] == "Leap"-%}
{% set repo_path = grains["osrelease"] -%}

{#- SL Micro -#}
{%- elif grains["osfullname"] == "SL-Micro" -%}
os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror")|default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SL-Micro/{{ grains['osrelease'] }}/x86_64/product/
    - refresh: True
{# REVIEW: Correct repo for 6.1? -#}
alp_sources_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror")|default("dist.nue.suse.com/ibs", true) }}/SUSE:/ALP:/Source:/Standard:/Core:/1.0:/Build/standard/
    - refresh: True
{% set repo_path = 'SLMicro' ~ grains['osrelease_info']|join %}

{#- Tumbleweed -#}
{%- elif grains["osfullname"] == "openSUSE Tumbleweed"-%}
{# REVIEW: Do we need to set repo-oss? #}
repo-oss:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/tumbleweed/repo/oss/
    - refresh: True
    - gpgcheck: False
{% set repo_path = grains["osfullname"]|replace(" ", "_") -%}
{% endif -%}

{#- Common -#}
salt_testsuite_dependencies_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:products:test-dependencies/{{ repo_path }}/
    - refresh: True
    - gpgcheck: False
    - priority: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:products:test-dependencies/{{ repo_path }}/repodata/repomd.xml.key

salt_testing_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ grains["salt_obs_flavor"] }}/{{ repo_path }}/
    - refresh: True
    - gpgcheck: False
    - priority: 1
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ grains["salt_obs_flavor"] }}/{{ repo_path }}/repodata/repomd.xml.key

## Packages

{% set installed_salt_pkgs = salt["pkg.list_pkgs"]().keys()|select("match", "python.*-salt")|list -%}
{% if grains["transactional"] -%}
{# FIXME: transactional_update.call currently drops --local
salt_packages_absent:
  module.run:
    - transactional_update.call:
      - pkg.remove
      - pkgs: {{ installed_salt_pkgs }}
-#}
salt_packages_absent:
  cmd.run:
    - name: transactional-update --continue --non-interactive --drop-if-no-change pkg remove {{ installed_salt_pkgs|join(" ")}}
{% else -%}
salt_packages_absent:
  pkg.removed:
    - pkgs: {{ installed_salt_pkgs }}
{% endif %}

{# Ensure docker is installed, and not podman-docker #}
{% set to_install = ["docker"] -%}
{% if grains["transactional"] -%}
{# FIXME: transactional_update.call currently drops --local
docker_installed:
  module.run:
    - transactional_update.call:
      - pkg.install
      - pkgs: {{ to_install }}
-#}
docker_installed:
  cmd.run:
    - name: transactional-update --continue --non-interactive --drop-if-no-change pkg install {{ to_install|join(" ")}}
{% else -%}        
docker_installed:
  pkg.installed:
    - pkgs: {{ to_install }}
{% endif %}  

{# TODO: pre-install all Python flavors #}
{% set to_install = ["python3-salt-testsuite", "python3-salt-test", "python3-salt"] -%}
{% if grains["transactional"] -%}
{# FIXME: transactional_update.call currently drops --local
salt_testsuite_installed:
  module.run:
    - transactional_update.call:
      - pkg.install
      - pkgs: {{ to_install }}
      - resolve_capabilities: true
      - fromrepo: salt_testing_repo
      - requires:
        - pkgrepo: salt_testing_repo
        - pkgrepo: salt_testsuite_dependencies_repo
-#}
salt_testsuite_installed:
  cmd.run:
    - name: transactional-update --continue --non-interactive --drop-if-no-change pkg install --capability --from salt_testing_repo {{ to_install|join(" ")}}
    - requires:
        - pkgrepo: salt_testing_repo
        - pkgrepo: salt_testsuite_dependencies_rep
{% else -%}
{# resolve_capabilities and fromrepo conflict, see bsc#1244067
salt_testsuite_installed:
  pkg.installed:
    - pkgs: {{ to_install }}
    - resolve_capabilities: true
    - fromrepo: salt_testing_repo
    - require:
      - pkgrepo: salt_testing_repo
      - pkgrepo: salt_testsuite_dependencies_repo
-#}
salt_testsuite_installed:
  cmd.run:
    - name: zypper --non-interactive install --capability --from salt_testing_repo {{ to_install|join(" ") }}
    - require:
      - pkgrepo: salt_testing_repo
      - pkgrepo: salt_testsuite_dependencies_repo
{% endif -%}  

## Services for running tests

docker_service_enabled:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] == 'SL-Micro' %}
  cmd.run:
    - name: transactional-update -c run systemctl enable docker
{% else %}
  service.running:
    - name: docker
{% endif %}
    - requires:
      - pkg: salt_testsuite_installed

{% if grains['osfullname'] == 'SLES' and '15.3' == grains['osrelease'] %}
update_buggy_pyzmq_version:
  pkg.latest:
    - name: python3-pyzmq
{% endif %}


{% if grains['osfullname'] == 'SLES' and grains['osrelease'] in ["15.3", "15.4"] %}
update_buggy_m2crypto_version:
  pkg.latest:
    - name: python3-M2Crypto
{% endif %}

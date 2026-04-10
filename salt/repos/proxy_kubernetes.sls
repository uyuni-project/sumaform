{% if 'proxy_kubernetes' in grains.get('roles') %}
{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_tumbleweed %}

{% if is_supported_os %}
{% set use_mirror_images = grains.get('use_mirror_images', False) %}
{% set mirror = grains.get('mirror', '') %}
{% set repo_host = mirror if use_mirror_images and mirror else 'dist.nue.suse.com' %}

{% if is_sles_15_7 %}
add_repo_ca_sles_proxy:
  pkgrepo.managed:
    - humanname: ca_suse
    - name: ca_suse
    - baseurl: http://{{ repo_host }}/ibs/SUSE:/CA/SLE_15_SP7/
    - enabled: 1
    - refresh: True
{% elif is_tumbleweed %}
add_repo_ca_tw_proxy:
  pkgrepo.managed:
    - humanname: ca_suse
    - name: ca_suse
    - baseurl: http://{{ repo_host }}/ibs/SUSE:/CA/openSUSE_Tumbleweed/
    - enabled: 1
    - refresh: True
{% endif %}

ca_suse_rke2_proxy:
  pkg.installed:
    - pkgs:
      - ca-certificates-suse
{% if is_sles_15_7 %}
    - require:
      - pkgrepo: add_repo_ca_sles_proxy
{% elif is_tumbleweed %}
    - require:
      - pkgrepo: add_repo_ca_tw_proxy
{% endif %}

{% endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

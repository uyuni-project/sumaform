{% if grains['os'] == 'SUSE' %}

{% if grains['osfullname'] == 'SLES' and grains['osrelease_info'][0] == 15 %}
{% set repo_path = "15" if grains["osrelease"] == 15 else "15-SP" + grains["osrelease_info"][1]|string %}
development_tools_repo_pool:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Module-Development-Tools/{{ repo_path }}/x86_64/product/
    - refresh: True

development_tools_repo_updates:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Module-Development-Tools/{{ repo_path }}/x86_64/update/
    - refresh: True

# needed for libhttp_parser_2_7_1, dependency of libgit2
sle_module_hpc_repo_pool:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Module-HPC/{{ repo_path }}/x86_64/product/
    - refresh: True

sle_module_hpc_repo_updates:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Module-HPC/{{ repo_path }}/x86_64/update/
    - refresh: True

containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SLE-Module-Containers/{{ repo_path }}/x86_64/product/
    - refresh: True

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/{{ repo_path }}/x86_64/update/
    - refresh: True

{% if grains['osrelease_info'][1] >= 3 %}
{% set repo_path = grains["osrelease"] %}
{% else %}
{% set repo_path = "SLE_15_SP" + grains["osrelease_info"][1]|string %}
{% endif %}

{% endif %}

remove_old_salt:
  cmd.run:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] == 'SL-Micro' %}
    - name: transactional-update -c -n pkg remove python3-salt; exit 0
{% else %}
    - name: zypper --non-interactive remove python3-salt; exit 0
{% endif %}

{% if grains['osfullname'] == 'SL-Micro' %}
{% set repo_path = 'SLMicro' + grains['osrelease_info'][0]|string + grains['osrelease_info'][1]|string %}
os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE/Products/SL-Micro/{{ grains['osrelease'] }}/x86_64/product/
    - refresh: True

alp_sources_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("dist.nue.suse.com/ibs", true) }}/SUSE:/ALP:/Source:/Standard:/Core:/1.0:/Build/standard/
    - refresh: True
{% endif %}

{% if grains['osfullname'] == 'Leap' %}
{% set repo_path = grains['osrelease'] %}
{% endif %}

{% if grains['osfullname'] == 'openSUSE Tumbleweed' %}
{% set repo_path = 'openSUSE_Tumbleweed' %}
repo-oss:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/tumbleweed/repo/oss/
    - refresh: True
    - gpgcheck: False
{% endif %}

salt_testsuite_dependencies_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:products:test-dependencies/{{ repo_path }}/
    - refresh: True
    - gpgcheck: 0
{% if grains['os'] == 'SUSE' %}
    - priority: 1
{% endif %}
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:products:test-dependencies/{{ repo_path }}/repodata/repomd.xml.key

salt_testing_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ grains["salt_obs_flavor"] }}/{{ repo_path }}/
    - refresh: True
    - gpgcheck: 0
{% if grains['os'] == 'SUSE' %}
    - priority: 1
{% endif %}
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ grains["salt_obs_flavor"] }}/{{ repo_path }}/repodata/repomd.xml.key

{% set salt_minion_is_installed = salt["pkg.info_installed"]("salt-minion").get("salt-minion", False) %}
install_salt_testsuite:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] == 'SL-Micro' %}
  cmd.run:
    - name: transactional-update -c -n pkg in --capability python3-salt-testsuite python3-salt-test python3-salt
{% else %}
  {# HACK: we call zypper manually to ensure right packages are installed regardless upgrade/downgrade #}
  cmd.run:
    {# We install docker first to ensure zypper does not resolve this dependency to podman-docker #}
    {% if salt_minion_is_installed %}
    - name: |
        zypper --non-interactive in --force docker
        zypper --non-interactive in --capability --from salt_testing_repo python3-salt salt python3-salt-testsuite salt-minion
    {% else %}
    - name: |
        zypper --non-interactive in --force docker
        zypper --non-interactive in --capability --from salt_testing_repo python3-salt salt python3-salt-testsuite
    {% endif %}
    - fromrepo: salt_testing_repo
{% endif %}
    - require:
      - pkgrepo: salt_testsuite_dependencies_repo
      - pkgrepo: salt_testing_repo

install_salt_tests_executor:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] == 'SL-Micro' %}
  cmd.run:
    - name: transactional-update -c -n pkg in python3-salt-test
{% else %}
  pkg.installed:
    - pkgs:
      - python3-salt-test
{% endif %}
    - require:
      - cmd: install_salt_testsuite

start_docker_service:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] == 'SL-Micro' %}
  cmd.run:
    - name: transactional-update -c run systemctl enable docker
{% else %}
  service.running:
    - name: docker
{% endif %}
    - requires:
      - pkg: install_salt_testsuite

{% endif %}


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

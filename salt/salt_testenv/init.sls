include:
  - default

{% if grains['os'] == 'SUSE' %}

{% if grains['osfullname'] == 'SLES' and grains['osrelease_info'][0] == 15 %}
{% set repo_path = "15" if grains["osrelease"] == 15 else "15-SP" + grains["osrelease_info"][1]|string %}
development_tools_repo_pool:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Development-Tools/{{ repo_path }}/x86_64/product/
    - refresh: True

development_tools_repo_updates:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Development-Tools/{{ repo_path }}/x86_64/update/
    - refresh: True

# needed for libhttp_parser_2_7_1, dependency of libgit2
sle_module_hpc_repo_pool:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-HPC/{{ repo_path }}/x86_64/product/
    - refresh: True

sle_module_hpc_repo_updates:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-HPC/{{ repo_path }}/x86_64/update/
    - refresh: True

containers_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SLE-Module-Containers/{{ repo_path }}/x86_64/product/
    - refresh: True

containers_updates_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/SLE-Module-Containers/{{ repo_path }}/x86_64/update/
    - refresh: True

{% if grains['osrelease_info'][1] >= 3 %}
{% set repo_path = grains["osrelease"] %}
{% else %}
{% set repo_path = "SLE_15_SP" + grains["osrelease_info"][1]|string %}
{% endif %}

{% endif %}


{% if grains['osfullname'] == 'SL-Micro' %}
{% set repo_path = 'SLMicro' + grains['osrelease_info'][0]|string + grains['osrelease_info'][1]|string %}
os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/SL-Micro/{{ grains['osrelease'] }}/x86_64/product/
    - refresh: True

alp_sources_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE:/ALP:/Source:/Standard:/Core:/1.0:/Build/standard/
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
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:products:test-dependencies/{{ repo_path }}/repodata/repomd.xml.key

salt_testing_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ grains["salt_obs_flavor"] }}/{{ repo_path }}/
    - refresh: True
    - gpgcheck: 0
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ grains["salt_obs_flavor"] }}/{{ repo_path }}/repodata/repomd.xml.key

install_salt_testsuite:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] == 'SL-Micro' %}
  cmd.run:
    - name: transactional-update -c -n pkg in python3-salt-testsuite python3-salt-test python3-salt
{% else %}
  pkg.latest:
    - pkgs: ["python3-salt-testsuite", "python3-salt-test", "python3-salt"]
{% endif %}
    - require:
      - pkgrepo: salt_testsuite_dependencies_repo
      - pkgrepo: salt_testing_repo

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

{% if grains['os'] == 'Debian' %}
    {% if grains['osrelease'] == '9' %}
        {% set repo_path = 'Debian_9.0' %}
    {% elif grains['osrelease'] == '10' %}
        {% set repo_path = 'Debian_10' %}
    {% elif grains['osrelease'] == '11' %}
        {% set repo_path = 'Debian_11' %}
    {% elif grains['osrelease'] == '12' %}
        {% set repo_path = 'Debian_12' %}
    {% endif %}
{% elif grains['osfullname'] == 'Ubuntu' %}
    {% if grains['osrelease'] == '20.04' %}
        {% set repo_path = 'Ubuntu_20.04' %}
    {% elif grains['osrelease'] == '22.04' %}
        {% set repo_path = 'Ubuntu_22.04' %}
    {% endif %}
{% elif grains['osfullname'] == 'AlmaLinux' %}
    {% if grains['osrelease_info'][0] == 8 %}
        {% set repo_path = 'AlmaLinux_8' %}
    {% elif grains['osrelease_info'][0] == 9 %}
        {% set repo_path = 'AlmaLinux_9' %}
    {% endif %}
{% elif grains['osfullname'] == 'CentOS Linux' %}
    {% if grains['osrelease_info'][0] == 7 %}
        {% set repo_path = 'CentOS_7' %}
    {% endif %}
{% elif grains['osfullname'] == 'SLES' %}
    {% if grains['osrelease_info'][0] == 12 %}
        {% set repo_path = 'SLE_12' %}
    {% elif grains['osrelease_info'][0] == 15 %}
        {% set repo_path = 'SLE_15' %}
    {% endif %}
{% elif grains['osfullname'] == 'Leap' %}
    {% if grains['osrelease_info'][0] == 15 %}
        {% set repo_path = 'openSUSE_Leap_15' %}
    {% endif %}
{% elif grains['osfullname'] == 'SL-Micro' %}
    {% if grains['osrelease'] == '6.0' %}
        {% set repo_path = 'SLMicro60' %}
    {% endif %}
{% endif %}

{% if grains['salt_obs_flavor'] != 'saltstack' %}

{% if grains["salt_obs_flavor"] == "saltstack:products" %}
    {% set salt_flavor_path = "saltstack:bundle" %}
{% elif grains["salt_obs_flavor"] == "saltstack:products:testing" %}
    {% set salt_flavor_path = "saltstack:bundle:testing" %}
{% elif grains["salt_obs_flavor"] == "saltstack:products:next" %}
    {% set salt_flavor_path = "saltstack:bundle:next" %}
{% else %}
    {{ raise("Unknown salt_obs_flavor set") }}
{% endif %}

salt_bundle_testsuite_repo:
  pkgrepo.managed:
{% if grains['os'] in ["Debian", "Ubuntu"] %}
    - humanname: salt_bundle_testsuite_repo
    - file: /etc/apt/sources.list.d/salt_bundle_testsuite_repo.list
    - name: deb http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ salt_flavor_path }}:testsuite/{{ repo_path }}/ /
    - key_url: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ salt_flavor_path }}:testsuite/{{ repo_path }}/Release.key
{% else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ salt_flavor_path }}:testsuite/{{ repo_path }}/
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:{{ salt_flavor_path }}:testsuite/{{ repo_path }}/repodata/repomd.xml.key
    - gpgcheck: 0
{% endif %}
    - refresh: True

install_salt_bundle_testsuite:
{% if grains['os_family'] == 'Suse' and grains['osfullname'] in ['SLE Micro', 'SL-Micro'] %}
  cmd.run:
    - name: transactional-update -c -n pkg in venv-salt-minion-testsuite
{% else %}
  pkg.installed:
    - name: venv-salt-minion-testsuite
{% endif %}
    - require:
      - pkgrepo: salt_bundle_testsuite_repo

{% endif %}

{% if grains['os_family'] == 'Suse' and grains['osfullname'] == 'SL-Micro' %}
copy_salt_classic_testsuite:
  cmd.run:
    - name: transactional-update -c run cp -r /usr/lib/python3.{{ grains["pythonversion"][1] }}/site-packages/salt-testsuite /opt/salt-testsuite-classic

copy_salt_bundle_testsuite:
  cmd.run:
    - name: transactional-update -c run cp -r /usr/lib/venv-salt-minion/lib/python3.{{ grains["pythonversion"][1] }}/site-packages/salt-testsuite /opt/salt-testsuite-bundle

reboot_transactional_system:
  module.run:
    - name: system.reboot
    - at_time: +1
    - order: last
{% endif %}

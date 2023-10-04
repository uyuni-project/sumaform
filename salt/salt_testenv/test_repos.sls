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
{% endif %}

{% if grains['osrelease_info'][1] >= 3 %}
{% set repo_path = grains["osrelease"] %}
{% else %}
{% set repo_path = "SLE_15_SP" + grains["osrelease_info"][1]|string %}
{% endif %}

salt_testsuite_dependencies_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:products:test-dependencies/{{ repo_path }}/
    - refresh: True
    - gpgcheck: 0
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:products:test-dependencies/{{ repo_path }}/repodata/repomd.xml.key

salt_testing_repo:
  pkgrepo.managed:
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:{{ grains["salt_obs_flavor"] }}/{{ repo_path }}/
    - refresh: True
    - gpgcheck: 0
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:{{ grains["salt_obs_flavor"] }}/{{ repo_path }}/repodata/repomd.xml.key

install_salt_testsuite:
  pkg.installed:
    - name: python3-salt-testsuite
    - require:
      - pkgrepo: salt_testsuite_dependencies_repo
      - pkgrepo: salt_testing_repo

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
{% endif %}

{% if grains["salt_obs_flavor"] == "products" %}
    {% set salt_flavor_path = "bundle" %}
{% elif grains["salt_obs_flavor"] == "products:testing" %}
    {% set salt_flavor_path = "bundle:testing" %}
{% elif grains["salt_obs_flavor"] == "products:next" %}
    {% set salt_flavor_path = "bundle:next" %}
{% else %}
    {{ raise("Unknown salt_obs_flavor set") }}
{% endif %}

salt_bundle_testsuite_repo:
  pkgrepo.managed:
{% if grains['os'] in ["Debian", "Ubuntu"] %}
    - humanname: salt_bundle_testsuite_repo
    - file: /etc/apt/sources.list.d/salt_bundle_testsuite_repo.list
    - name: deb http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:{{ salt_flavor_path }}:testsuite/{{ repo_path }}/ /
    - key_url: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:{{ salt_flavor_path }}:testsuite/{{ repo_path }}/Release.key
{% else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:{{ salt_flavor_path }}:testsuite/{{ repo_path }}/
    - gpgkey: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:saltstack:{{ salt_flavor_path }}:testsuite/{{ repo_path }}/repodata/repomd.xml.key
    - gpgcheck: 0
{% endif %}
    - refresh: True

install_salt_bundle_testsuite:
  pkg.installed:
    - name: venv-salt-minion-testsuite
    - require:
      - pkgrepo: salt_bundle_testsuite_repo

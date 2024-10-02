{% if grains['os'] == 'Debian' %}
    {% if grains['osrelease'] == '11' %}
        {% set repo_path = 'Debian_11' %}
    {% elif grains['osrelease'] == '12' %}
        {% set repo_path = 'Debian_12' %}
    {% endif %}
{% elif grains['osfullname'] == 'Ubuntu' %}
    {% if grains['osrelease'] == '20.04' %}
        {% set repo_path = 'Ubuntu_20.04' %}
    {% elif grains['osrelease'] == '22.04' %}
        {% set repo_path = 'Ubuntu_22.04' %}
    {% elif grains['osrelease'] == '24.04' %}
        {% set repo_path = 'Ubuntu_24.04' %}
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

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []

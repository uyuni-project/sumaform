{% if grains.get('testsuite') | default(false, true) %}

include:
  - server

minima:
  archive.extracted:
    - name: /usr/bin
    - source: https://github.com/uyuni-project/minima/releases/download/v0.4/minima-linux-amd64.tar.gz
    - source_hash: https://github.com/uyuni-project/minima/releases/download/v0.4/minima-linux-amd64.tar.gz.sha512
    - archive_format: tar
    - enforce_toplevel: false
    - keep: True
    - overwrite: True

test_repo_rpm_updates:
  cmd.run:
    - name: minima sync
    - env:
      - MINIMA_CONFIG: |
          - url: http://{{ grains.get("mirror") | default("download.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Updates/rpm
            path: /srv/www/htdocs/pub/TestRepoRpmUpdates
    - require:
      - archive: minima

another_test_repo:
  file.symlink:
    - name: /srv/www/htdocs/pub/AnotherRepo
    - target: TestRepoRpmUpdates
    - require:
      - cmd: test_repo_rpm_updates

test_repo_debian_updates:
  cmd.script:
    - name: salt://server/download_ubuntu_repo.sh
    - args: "TestRepoDebUpdates {{ grains.get('mirror') | default('download.opensuse.org', true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Updates/deb/"
    - creates: /srv/www/htdocs/pub/TestRepoDebUpdates/Release
    - require:
      - pkg: testsuite_packages
      {% if 'build_image' and 'paygo' not in grains.get('product_version') | default('', true) %}
      - pkg: testsuite_salt_packages
      {% endif %}

# modify Cobbler to be executed from remote-machines..
{% set products_using_new_cobbler_version = ["uyuni-master", "uyuni-released", "uyuni-pr", "head", "4.3-released", "4.3-nightly", "4.3-pr"] %}
{% set cobbler_use_settings_yaml = grains.get('product_version') | default('', true) in products_using_new_cobbler_version %}
{% if 'build_image' and 'paygo' not in grains.get('product_version') | default('', true) %}
cobbler_configuration:
    service:
    - name : cobblerd.service
    - running
    - enable: True
    - watch :
{% if cobbler_use_settings_yaml %}
      - file : /etc/cobbler/settings.yaml
{% else %}
      - file : /etc/cobbler/settings
{% endif %}
    - require:
      - sls: server
    file.replace:
{% if cobbler_use_settings_yaml %}
    - name: /etc/cobbler/settings.yaml
    - pattern: "redhat_management_permissive: false"
    - repl: "redhat_management_permissive: true"
{% else %}
    - name: /etc/cobbler/settings
    - pattern: "redhat_management_permissive: 0"
    - repl: "redhat_management_permissive: 1"
{% endif %}
    - require:
      - sls: server
{% endif %}

testsuite_packages:
  pkg.installed:
    - pkgs:
      - expect
      - aaa_base-extras
      - wget
      - OpenIPMI
    {% if 'build_image' and 'paygo' not in grains.get('product_version') | default('', true) %}
    - require:
      - sls: repos
    {% endif %}

{% if 'build_image' and 'paygo' not in grains.get('product_version') | default('', true) %}
testsuite_salt_packages:
  pkg.installed:
    - pkgs:
      - salt-ssh
{% if 'head' in grains.get('product_version') or 'uyuni-master' in grains.get('product_version') or 'nightly' in grains.get('product_version') or 'uyuni-pr' in grains.get('product_version') or '4.3-pr' in grains.get('product_version') %}
    - fromrepo: testing_overlay_devel_repo
{% endif %}
    - require:
      - sls: repos
{% endif %}

{% set products_to_use_salt_bundle = ["uyuni-master", "uyuni-pr", "head", "4.3-released", "4.3-nightly", "4.3-pr", "4.2-nightly", "4.2-released"] %}
{% if grains.get('product_version') | default('', true) in products_to_use_salt_bundle %}

# The following states are needed to ensure "venv-salt-minion" is used during bootstrapping,
# in cases where the "venv-salt-minion" is not available in the bootstrap repository.
# Once bootstrap repository contains the venv-salt-minion before running bootstrap
# then these states can be removed

create_pillar_top_sls_to_assign_salt_bundle_config:
  file.managed:
    - name: /srv/pillar/top.sls
    - contents: |
        base:
          '*':
            - salt_bundle_config
    - require:
        - sls: server

custom_pillar_to_force_salt_bundle:
  file.managed:
    - name: /srv/pillar/salt_bundle_config.sls
    - contents: |
        mgr_force_venv_salt_minion: True
    - require:
      - file: create_pillar_top_sls_to_assign_salt_bundle_config
{% endif %}

enable_salt_content_staging_window:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: 'java.salt_content_staging_window = (.*)'
    - repl: 'java.salt_content_staging_window = 0.033'
    - append_if_not_found: True
    - require:
      - cmd: server_setup

enable_salt_content_staging_advance:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: 'java.salt_content_staging_advance = (.*)'
    - repl: 'java.salt_content_staging_advance = 0.05'
    - append_if_not_found: True
    - require:
      - cmd: server_setup

enable_kiwi_os_image_building:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: 'java.kiwi_os_image_building_enabled = (.*)'
    - repl: 'java.kiwi_os_image_building_enabled = true'
    - append_if_not_found: True
    - require:
      - cmd: server_setup

tomcat:
  service.running:
    - watch:
      - file: enable_salt_content_staging_window
      - file: enable_salt_content_staging_advance

dump_salt_event_log:
    cmd.run:
        - name: |-
            exec 0>&- # close stdin
            exec 1>&- # close stdout
            exec 2>&- # close stderr
            nohup salt-run state.event pretty=True > /var/log/rhn/salt-event.log &

{% endif %}

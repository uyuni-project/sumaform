{% if grains.get('testsuite') | default(false, true) %}

include:
  - server

minima:
  archive.extracted:
    - name: /usr/bin
    - source: https://github.com/moio/minima/releases/download/v0.4/minima-linux-amd64.tar.gz
    - source_hash: https://github.com/moio/minima/releases/download/v0.4/minima-linux-amd64.tar.gz.sha512
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
    - args: "TestRepoDebUpdates {{ grains.get('mirror') | default('download.opensuse.org', true) }}/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Updates/deb"
    - creates: /srv/www/htdocs/pub/TestRepoDebUpdates/Release
    - require:
      - pkg: testsuite_packages
      - pkg: testsuite_salt_packages

# modify cobbler to be executed from remote-machines..

cobbler_configuration:
    service:
    - name : cobblerd.service
    - running
    - enable: True
    - watch :
      - file : /etc/cobbler/settings
    - require:
      - sls: server
    file.replace:
    - name: /etc/cobbler/settings
    - pattern: "redhat_management_permissive: 0"
    - repl: "redhat_management_permissive: 1"
    - require:
      - sls: server

testsuite_packages:
  pkg.installed:
    - pkgs:
      - expect
      - aaa_base-extras
      - wget
      - OpenIPMI
    - require:
      - sls: repos

testsuite_salt_packages:
  pkg.installed:
    - pkgs:
      - salt-ssh
    - fromrepo: server_devel_repo
    - require:
      - sls: repos

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

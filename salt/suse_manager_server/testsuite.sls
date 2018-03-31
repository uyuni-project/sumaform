{% if grains.get('testsuite') | default(false, true) %}

include:
  - suse_manager_server

fedora_autoinstallation_initrd_file:
  file.managed:
    - name: /install/Fedora_12_i386/images/pxeboot/initrd.img
    - contents:
      - This is mocked contents for /pxeboot/initrd.img
    - makedirs: True

fedora_autoinstallation_vmlinuz_file:
  file.managed:
    - name: /install/Fedora_12_i386/images/pxeboot/vmlinuz
    - contents:
      - This is mocked contents for /pxeboot/vmlinuz
    - makedirs: True

sles_autoinstallation_initrd_file:
  file.managed:
    - name: /install/SLES11-SP1-x86_64/DVD1/boot/x86_64/loader/initrd
    - contents:
      - This is mocked contents for /boot/x86_64/loader/initrd
    - makedirs: True

sles_autoinstallation_linux_file:
  file.managed:
    - name: /install/SLES11-SP1-x86_64/DVD1/boot/x86_64/loader/linux
    - contents:
      - This is mocked contents for /boot/x86_64/loader/linux
    - makedirs: True

test_package_without_vendor_file:
  file.managed:
    - name: /root/subscription-tools-1.0-0.noarch.rpm
    - source: salt://suse_manager_server/testsuite/subscription-tools-1.0-0.noarch.rpm

test_autoinstallation_file:
  file.managed:
    - name: /install/empty.xml
    - source: salt://suse_manager_server/testsuite/empty.xml
    - makedirs: True

test_vcenter_file:
  file.managed:
    - name: /var/tmp/vCenter.json
    - source: salt://suse_manager_server/testsuite/vCenter.json

minima:
  archive.extracted:
    - name: /usr/bin
    - source: https://github.com/moio/minima/releases/download/v0.4/minima-linux-amd64.tar.gz
    - source_hash: https://github.com/moio/minima/releases/download/v0.4/minima-linux-amd64.tar.gz.sha512
    - archive_format: tar
    - enforce_toplevel: false
    - keep: True
    - overwrite: True

test_repo:
  cmd.run:
    - name: minima sync
    - env:
      - MINIMA_CONFIG: |
          - url: http://download.suse.de/ibs/Devel:/Galaxy:/TestsuiteRepo/SLE_12_SP1
            path: /srv/www/htdocs/pub/TestRepo
    - require:
      - archive: minima

another_test_repo:
  file.symlink:
    - name: /srv/www/htdocs/pub/AnotherRepo
    - target: TestRepo
    - require:
      - cmd: test_repo

# modify cobbler to be executed from remote-machines..

cobbler_configuration:
    service:
    - name : cobblerd.service
    - running
    - enable: True
    - watch :
      - file : /etc/cobbler/settings
    - require:
      - sls: suse_manager_server
    file.replace:
    - name: /etc/cobbler/settings
    - pattern: "redhat_management_permissive: 0"
    - repl: "redhat_management_permissive: 1"
    - require:
      - sls: suse_manager_server

expect:
  pkg.installed

aaa_base-extras:
  pkg.installed

salt-ssh:
  pkg.installed:
    - require:
      - sls: suse_manager_server.repos

enable_salt_content_staging_window:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: 'java.salt_content_staging_window = (.*)'
    - repl: 'java.salt_content_staging_window = 0.033'
    - require:
      - cmd: suse_manager_setup

enable_salt_content_staging_advance:
  file.replace:
    - name: /etc/rhn/rhn.conf
    - pattern: 'java.salt_content_staging_advance = (.*)'
    - repl: 'java.salt_content_staging_advance = 0.05'
    - require:
      - cmd: suse_manager_setup

tomcat:
  service.running:
    - watch:
      - file: enable_salt_content_staging_window
      - file: enable_salt_content_staging_advance

{% endif %}

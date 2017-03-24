{% if grains['for_testsuite_only'] %}

include:
  - suse-manager
  - suse-manager.repos

testsuite_authorized_key:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://controller/id_rsa.pub
    - makedirs: True

anaconda-package-file:
  file.managed:
    - name: /root/anaconda-18.37.11-1.fc18.x86_64.rpm
    - source: http://archive.fedoraproject.org/pub/archive/fedora/linux/releases/18/Everything/x86_64/os/Packages/a/anaconda-18.37.11-1.fc18.x86_64.rpm
    - source_hash: sha1=faba3de399515f76422a2b0d693273c285b4baa7

fedora-autoinstallation-initrd-file:
  file.managed:
    - name: /install/Fedora_12_i386/images/pxeboot/initrd.img
    - source: http://archive.fedoraproject.org/pub/archive/fedora/linux/releases/12/Fedora/i386/os/images/pxeboot/initrd.img
    - source_hash: sha1=ce78f88281640fbb9ce93435cbc21e8de0d9862d
    - makedirs: True

fedora-autoinstallation-vmlinuz-file:
  file.managed:
    - name: /install/Fedora_12_i386/images/pxeboot/vmlinuz
    - source: http://archive.fedoraproject.org/pub/archive/fedora/linux/releases/12/Fedora/i386/os/images/pxeboot/vmlinuz
    - source_hash: sha1=147c8c50d83639dd8523ada478621b456f1fb23e
    - makedirs: True

sles-autoinstallation-initrd-file:
  file.managed:
    - name: /install/SLES11-SP1-x86_64/DVD1/boot/x86_64/loader/initrd
    - source: http://schnell.nue.suse.com/SLE11/SLES-11-SP1-GM/x86_64/DVD1/boot/x86_64/loader/initrd
    - source_hash: sha1=965da7bb9a6b21d4f0273ac288a3016a2671bb51
    - makedirs: True

sles-autoinstallation-linux-file:
  file.managed:
    - name: /install/SLES11-SP1-x86_64/DVD1/boot/x86_64/loader/linux
    - source: http://schnell.nue.suse.com/SLE11/SLES-11-SP1-GM/x86_64/DVD1/boot/x86_64/loader/linux
    - source_hash: sha1=f18abd366f40c12971b54ac787eb9737012badab
    - makedirs: True

test-package-without-vendor-file:
  file.managed:
    - name: /root/subscription-tools-1.0-0.noarch.rpm
    - source: salt://suse-manager/testsuite/subscription-tools-1.0-0.noarch.rpm

test-autoinstallation-file:
  file.managed:
    - name: /install/empty.xml
    - source: salt://suse-manager/testsuite/empty.xml
    - makedirs: True

test-vcenter-file:
  file.managed:
    - name: /var/tmp/vCenter.json
    - source: salt://suse-manager/testsuite/vCenter.json

lftp:
  pkg.installed:
    - require:
      - sls: suse-manager.repos

test-repo:
  cmd.run:
    - name: lftp -c "open http://download.suse.de; mirror -x repocache ibs/Devel:/Galaxy:/TestsuiteRepo/SLE_12_SP1 /srv/www/htdocs/pub/TestRepo"
    - require:
      - pkg: lftp

another-test-repo:
  file.symlink:
    - name: /srv/www/htdocs/pub/AnotherRepo
    - target: TestRepo
    - require:
      - cmd: test-repo

# modify cobbler to be executed from remote-machines.. 

config-cobbler:
    service:
    - name : cobblerd.service
    - running
    - enable: True
    - watch : 
      - file : /etc/cobbler/settings
    - require:
      - sls: suse-manager
    file.replace:
    - name: /etc/cobbler/settings
    - pattern: "redhat_management_permissive: 0"
    - repl: "redhat_management_permissive: 1"
    - require:
      - sls: suse-manager

expect:
  pkg.installed

aaa_base-extras:
  pkg.installed

{% endif %}

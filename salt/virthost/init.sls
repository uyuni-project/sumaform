include:
  - repos

virthost_packages:
  pkg.installed:
    - pkgs:
        {% if '15' in grains['osrelease'] %}
        - patterns-server-kvm_server
        - python3-six  # Workaround missing virt-manager-common dependency
        {% elif grains['osfullname'] == 'Leap' %}
        - patterns-openSUSE-kvm_server
        {% else %}
        - patterns-sles-kvm_server
        {% endif %}
        - libvirt-client
        - qemu-tools
        - guestfs-tools
    - require:
      - sls: repos

{% if grains['osrelease'] == '12.4' %}
# Workaround for guestfs appliance missing libaugeas0 on 12SP4
guestfs-fix:
  file.append:
    - name: /usr/lib64/guestfs/supermin.d/packages
    - text: libaugeas0
    - require:
      - pkg: virthost_packages
{% endif %}

libvirtd_service:
  service.running:
    - name: libvirtd
    - enable: True
    - require:
      - pkg: virthost_packages

default-pool.xml:
  file.managed:
    - name: /root/default-pool.xml
    - source: salt://virthost/default-pool.xml

default-pool_destroyed:
  cmd.run:
    - name: 'virsh pool-destroy default'
    - onlyif: 'virsh pool-dumpxml default'
    - require:
      - service: libvirtd_service
      - file: default-pool.xml

default-pool_undefined:
  cmd.run:
    - name: 'virsh pool-undefine default'
    - onlyif: 'virsh pool-dumpxml default'
    - require:
      - cmd: default-pool_destroyed

default-pool_defined:
  cmd.run:
    - name: 'virsh pool-define /root/default-pool.xml'
    - require:
      - cmd: default-pool_undefined
      - file: default-pool.xml

default-pool_autostart:
  cmd.run:
    - name: 'virsh pool-autostart default'
    - require:
      - cmd: default-pool_defined

default_virt_pool_start:
  cmd.run:
    - name: 'virsh pool-start default'
    - require:
      - cmd: default-pool_defined

default-net.xml:
  file.managed:
    - name: /root/default-net.xml
    - source: salt://virthost/default-net.xml

default-net_destroyed:
  cmd.run:
    - name: 'virsh net-destroy default'
    - onlyif: 'virsh net-dumpxml default'
    - require:
      - service: libvirtd_service
      - file: default-net.xml

default-net_undefined:
  cmd.run:
    - name: 'virsh net-undefine default'
    - onlyif: 'virsh net-dumpxml default'
    - require:
      - cmd: default-net_destroyed

default-net_defined:
  cmd.run:
    - name: 'virsh net-define /root/default-net.xml'
    - require:
      - cmd: default-net_undefined
      - file: default-net.xml

default-net_autostart:
  cmd.run:
    - name: 'virsh net-autostart default'
    - require:
      - cmd: default-net_defined

default_virt_net_start:
  cmd.run:
    - name: 'virsh net-start default'
    - require:
      - cmd: default-net_defined

fake_dmidecode_file:
  file.managed:
    - name: /root/baremetal-dmidecode.bin
    - source: salt://virthost/baremetal-dmidecode.bin

dmidecode_backup:
  file.rename:
    - name: /usr/sbin/dmidecode.bak
    - source: /usr/sbin/dmidecode
    - onlyif: test -e /usr/sbin/dmidecode.bak

dmidecode_wrapper:
  file.managed:
    - name: /usr/sbin/dmidecode
    - source: salt://virthost/dmidecode
    - mode: 655
    - require:
      - file: /usr/sbin/dmidecode.bak

fake_systemd_detect_virt:
  file.managed:
    - name: /usr/bin/systemd-detect-virt
    - source: salt://virthost/systemd-detect-virt
    - mode: 655

disk-image-template.qcow2:
  file.managed:
    - name: /var/testsuite-data/disk-image-template.qcow2
    - source: {{ grains['hvm_disk_image'] }}
    - skip_verify: True
    - mode: 655
    - makedirs: True

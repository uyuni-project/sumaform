include:
  - repos

# SLES JeOS doesn't ship the KVM modules
no_kernel_default_base:
  pkg.removed:
    - name: kernel-default-base

virthost_packages:
  pkg.installed:
    - pkgs:
        {% if '15' in grains['osrelease'] %}
        - patterns-server-kvm_server
        - python3-six  # WORKAROUND: missing virt-manager-common dependency
        - libvirt-daemon-qemu
        {% elif grains['osfullname'] == 'Leap' %}
        - patterns-openSUSE-kvm_server
        {% else %}
        - patterns-sles-kvm_server
        {% endif %}
        - libvirt-client
        - qemu-tools
        - guestfs-tools
        - tar # WORKAROUND: missing supermin tar dependency bsc#1134334
        - kernel-default
        - tuned
        - irqbalance
    - require:
      - sls: repos
      - pkg: no_kernel_default_base

{% if grains['osrelease'] == '12.4' %}
# WORKAROUND for guestfs appliance missing libaugeas0 on 12SP4
guestfs-fix:
  file.append:
    - name: /usr/lib64/guestfs/supermin.d/packages
    - text: libaugeas0
    - require:
      - pkg: virthost_packages
{% endif %}

# WORKAROUND for bsc#1181264
{% if grains['osrelease'] == '15.3' and grains['hypervisor'] == 'kvm' %}
no-50-xen-hvm-x86_64.json:
  file.absent:
    - name: /usr/share/qemu/firmware/50-xen-hvm-x86_64.json
{% endif %}

fake_systemd_detect_virt:
  file.managed:
    - name: /usr/bin/systemd-detect-virt
    - source: salt://virthost/systemd-detect-virt
    - mode: 655

fake_virt_what:
  file.managed:
    - name: /usr/sbin/virt-what
    - mode: 655
    - contents: "# Fake from sumaform to mock physical machine"

{% if grains['hvm_disk_image'] %}
disk-image-template.qcow2:
  file.managed:
    - name: /var/testsuite-data/disk-image-template.qcow2
    - source: {{ grains['hvm_disk_image'] }}
    {% if grains['hvm_disk_image_hash'] %}
    - source_hash: {{ grains['hvm_disk_image_hash'] }}
    {% else %}
    - skip_verify: True
    {% endif %}
    - mode: 655
    - makedirs: True
{% endif %}

ifcfg-eth0:
  file.managed:
    - name: /etc/sysconfig/network/ifcfg-eth0
    - contents: |
        STARTMODE=auto
        BOOTPROTO=none

ifcfg-br0:
  file.managed:
    - name: /etc/sysconfig/network/ifcfg-br0
    - contents: |
        STARTMODE=onboot
        BOOTPROTO=dhcp
        BRIDGE=yes
        BRIDGE_PORTS=eth0

reboot:
  module.run:
    - name: system.reboot
    - at_time: +2
    - order: last

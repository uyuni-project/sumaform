include:
  - repos

no-xen-tools:
  pkg.removed:
    - name: xen-tools-domU

virthost_packages:
  pkg.installed:
    - pkgs:
        {% if '15' in grains['osrelease'] %}
        - patterns-server-{{ grains['hypervisor']|lower() }}_server
        - python3-six  # Workaround missing virt-manager-common dependency
        - libvirt-daemon-qemu
        {% elif grains['osfullname'] == 'Leap' %}
        - patterns-openSUSE-{{ grains['hypervisor']|lower() }}_server
        {% else %}
        - patterns-sles-{{ grains['hypervisor']|lower() }}_server
        {% endif %}
        - libvirt-client
        - qemu-tools
        - guestfs-tools
        - tar # HACK: workaround missing supermin tar dependency. See boo#1134334
    - require:
      - sls: repos
      - pkg: no-xen-tools

{% if grains['osrelease'] == '12.4' %}
# Workaround for guestfs appliance missing libaugeas0 on 12SP4
guestfs-fix:
  file.append:
    - name: /usr/lib64/guestfs/supermin.d/packages
    - text: libaugeas0
    - require:
      - pkg: virthost_packages
{% endif %}
fake_systemd_detect_virt:
  file.managed:
    - name: /usr/bin/systemd-detect-virt
    - source: salt://virthost/systemd-detect-virt
    - mode: 655

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

network-restart:
  cmd.run:
    - name: systemctl restart network
    - require:
        - file: ifcfg-br0
        - file: ifcfg-eth0

{% if grains['hypervisor']|lower() == 'xen' %}
{% if grains['xen_disk_image'] %}
disk-image-template-xenpv.qcow2:
  file.managed:
    - name: /var/testsuite-data/disk-image-template-xenpv.qcow2
    - source: {{ grains['hvm_disk_image'] }}
    {% if grains['hvm_disk_image_hash'] %}
    - source_hash: {{ grains['hvm_disk_image_hash'] }}
    {% else %}
    - skip_verify: True
    {% endif %}
    - mode: 655
    - makedirs: True
{% endif %}

set_xen_default:
  bootloader.grub_set_default:
    - name: Xen
    - onchanges:
        - pkg: virthost_packages

lower_dom0_memory:
  file.replace:
    - name: /etc/default/grub
    - pattern: ^GRUB_CMDLINE_XEN="[^"]*"
    - repl: GRUB_CMDLINE_XEN="dom0_mem=819200"

rebuild_grub_cfg:
  cmd.run:
    - name: grub2-mkconfig -o /boot/grub2/grub.cfg
    - onchanges:
        - bootloader: set_xen_default
        - file: lower_dom0_memory

reboot:
  module.run:
    - name: system.reboot
    - at_time: +1
    - onchanges:
        - cmd: rebuild_grub_cfg
{% endif %}

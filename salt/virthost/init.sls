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
{% if grains['osrelease'] == '15.3' %}
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

{% if grains['hvm_disk_image'] %}
{% for os_type in grains.get('hvm_disk_image') %}
{{ os_type }}-disk-image-template.qcow2:
  file.managed:
    - name: /var/testsuite-data/{{ os_type }}-disk-image-template.qcow2
    - source: {{ salt['grains.get']('hvm_disk_image:' ~ os_type ~ ':image') }}
    {% if salt['grains.get']('hvm_disk_image:' ~ os_type ~ ':hash') %}
    - source_hash: {{ salt['grains.get']('hvm_disk_image:' ~ os_type ~ ':hash') }}
    {% else %}
    - skip_verify: True
    {% endif %}
    - mode: 655
    - makedirs: True

### adjustments for cloud init and the test suite ---
# https://cloudinit.readthedocs.io/en/latest/topics/examples.html
rezise-{{ os_type }}-disk-image-template:
  cmd.run:
    - name: qemu-img resize /var/testsuite-data/{{ os_type }}-disk-image-template.qcow2 3G
    - requires:
      - pgk: qemu-tools
      - file: /var/testsuite-data/{{ os_type }}-disk-image-template.qcow2

cloudinit-directory-{{ os_type }}:
  file.directory:
    - name: /var/testsuite-data/cloudinit

cloudinit-meta-data-{{ os_type }}:
  file.managed:
    - name: /var/testsuite-data/cloudinit/meta-data
    - contents: |
        instance-id: {{ salt['grains.get']('hvm_disk_image:' ~ os_type ~ ':hostname') }}
        local-hostname: {{ salt['grains.get']('hvm_disk_image:' ~ os_type ~ ':hostname') }}.{{ grains.get('domain') }}

cloudinit-network-config-{{ os_type }}:
  file.managed:
    - name: /var/testsuite-data/cloudinit/network-config
    - contents: |
        network:
          version: 1
          config:
          - type: physical
            name: eth0
            subnets:
              - type: dhcp

cloudinit-user-data-{{ os_type }}:
  file.managed:
    - name: /var/testsuite-data/cloudinit/user-data
    - contents: |
        #cloud-config
        # vim: syntax=yaml

        # root user configuration
        disable_root: false
        ssh_pwauth: true
        chpasswd:
          expire: false
          list: |
            root:linux
        ssh_authorized_keys:
          {% for key in grains.get('authorized_keys') %}
          - {{ key }}
          {% endfor %}
        # adjust configuration files
        write_files:
        - content: |
           master: {{ grains.get('server') }}
           server_id_use_crc: adler32
           enable_legacy_startup_events: False
           enable_fqdns_grains: False
          path: /etc/salt/minion
        - content: |
           [server]
           domain-name={{ grains.get('domain') }}
           use-ipv4=yes
           use-ipv6=no
           ratelimit-interval-usec=1000000
           ratelimit-burst=1000
           [wide-area]
           enable-wide-area=yes
           [publish]
           publish-hinfo=no
           publish-workstation=no
          path: /etc/avahi/avahi-daemon.conf
        - content: |
           .local
           .tf.local
           .{{ grains.get('domain') }}
          path: /etc/mdns.allow
        - content: |
           passwd:         compat
           group:          compat
           shadow:         compat
           hosts:          files mdns [NOTFOUND=return] dns
           networks:       files dns
           aliases:        files usrfiles
           ethers:         files usrfiles
           gshadow:        files usrfiles
           netgroup:       files nis
           protocols:      files usrfiles
           publickey:      files
           rpc:            files usrfiles
           services:       files usrfiles
           automount:      files nis
           bootparams:     files
           netmasks:       files
          path: /etc/nsswitch.conf
        runcmd:
        - hostnamectl hostname {{ salt['grains.get']('hvm_disk_image:' ~ os_type ~ ':hostname') }}.{{ grains.get('domain') }}
{% if os_type == 'sles' %}
        # add SLES 15 SP4 base repository
        - zypper --non-interactive ar "http://download.suse.de/ibs/SUSE/Products/SLE-Module-Basesystem/15-SP4/x86_64/product/" SLE-Module-Basesystem15-SP4-Pool
{% endif %}
        - zypper --non-interactive ref
        - zypper --non-interactive install avahi
        - rm /etc/avahi/avahi-daemon.conf
        - mv /etc/avahi/avahi-daemon.conf.rpmorig /etc/avahi/avahi-daemon.conf
        - rm /etc/nsswitch.conf
        - mv /etc/nsswitch.confbak /etc/nsswitch.conf
        - systemctl enable avahi-daemon.service
        - systemctl start avahi-daemon.service
        - systemctl restart salt-minion.service

create-vm-cloudinit-disk-{{ os_type }}:
  cmd.run:
    - name: mkisofs -o /var/testsuite-data/cloudinit-disk-{{ os_type }}.iso -volid cidata -joliet -rock /var/testsuite-data/cloudinit
    - creates: /var/testsuite-data/cloudinit-disk-{{ os_type }}.iso
    - requires:
      - pkg: mkisofs
      - file: /var/testsuite-data/cloudinit/network-config
      - file: /var/testsuite-data/cloudinit/user-data
      - file: /var/testsuite-data/cloudinit/meta-data
{% endfor %}
{% endif %}
###---

reboot:
  module.run:
    - name: system.reboot
    - at_time: +2
    - order: last

include:
  - repos

virthost_packages:
  pkg.installed:
    - pkgs:
        {% if '15' in grains['osrelease'] %}
        - patterns-server-kvm_server
        - python3-six  # Workaround missing virt-manager-common dependency
        - libvirt-daemon-qemu
        {% elif grains['osfullname'] == 'Leap' %}
        - patterns-openSUSE-kvm_server
        {% else %}
        - patterns-sles-kvm_server
        {% endif %}
        - libvirt-client
        - qemu-tools
        - guestfs-tools
        - tar # HACK: workaround missing supermin tar dependency. See boo#1134334
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

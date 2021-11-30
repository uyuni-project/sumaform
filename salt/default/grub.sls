# HACK
# Use symlinks to boot SLES 11 SP4
# That's needed when we patch the kernel on such a system
{% if grains['osfullname'] == 'SLES' %}

{% if grains['osrelease'] == '11.4' %}
grub_hack:
  file.replace:
    - name: /boot/grub/menu.lst
    - pattern: ^(title.*)$
    - count: 1
    - repl: |
       title sles11sp4_fixed
         root (hd0,0)
         kernel /boot/vmlinuz vga=0x314 splash=silent console=tty0 console=ttyS0,115200 root=/dev/vda1 disk=/dev/vda nomodeset elevator=noop showopts
         initrd /boot/initrd
       \1
{% endif %}

{% endif %}

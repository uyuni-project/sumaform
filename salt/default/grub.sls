# HACK
# This problem should be fixed when we build the image
#   https://build.suse.de/package/show/Devel:Galaxy:Terraform:Images/sles11sp4
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
         kernel /boot/vmlinuz-3.0.101-108.126-default vga=0x314 splash=silent console=tty0 console=ttyS0,115200 root=/dev/vda1 disk=/dev/vda nomodeset elevator=noop showopts
         initrd /boot/initrd-3.0.101-108.126-default
       \1
{% endif %}

{% endif %}

# Configure serial console
yum -y install grub2-tools

# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/sec-GRUB_2_over_Serial_Console.html#sec-Configuring_GRUB_2
cat > /etc/default/grub <<EOF
GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL=serial
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"
GRUB_TERMINAL_OUTPUT="console"
GRUB_DISABLE_RECOVERY="true"
EOF

grub2-mkconfig -o /boot/grub2/grub.cfg

# remove uuid
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-e*

# install cloud-init
yum -y install cloud-init

# install salt-minion
yum -y install epel-release
# yum -y install salt-minion

# configure cloud init 'cloud-user' as sudo
# this is not configured via default cloudinit config
#cat > /etc/cloud/cloud.cfg.d/02_user.cfg <<EOL
#system_info:
#  default_user:
#    name: cloud-user
#    lock_passwd: true
#    gecos: Cloud user
#    groups: [wheel, adm]
#    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
#    shell: /bin/bash
#EOL

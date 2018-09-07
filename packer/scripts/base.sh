# Install basic packages
yum -y update
yum -y install wget curl openssh-server

# Install root certificates
yum -y install ca-certificates

# Install multicast DNS plugin for nss from epel
yum -y install epel-release
yum -y install nss-mdns

# Make SSH faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

# We might use virtio interfaces, undeclare Ethernet
sed -i 's/^TYPE="Ethernet"/# &/' /etc/sysconfig/network-scripts/ifcfg-eth0

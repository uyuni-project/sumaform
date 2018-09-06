yum -y update
yum -y install wget curl openssh-server

# Install root certificates
yum -y install ca-certificates

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

# We might use virtio interfaces, undeclare Ethernet
for card in eth0 eth1; do
  sed -i 's/^TYPE="Ethernet"/# &/' /etc/sysconfig/network-scripts/ifcfg-$card
done

# Install the EPEL repo in order to install nss-mdns
yum -y install epel-release
yum -y install nss-mdns

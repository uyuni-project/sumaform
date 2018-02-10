yum -y update
yum -y install wget curl openssh-server

# Install root certificates
yum -y install ca-certificates

# Enable password login via ssh
sed -i "/PasswordAuthentication no/d" /etc/ssh/sshd_config

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

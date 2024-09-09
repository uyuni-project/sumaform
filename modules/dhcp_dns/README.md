This module creates a VM that hosts a DHCP and a DNS server.

It is meant to be used on the private network, together with the proxy
(5.0 and onwards), the PXE boot minions, and the hypervisor.

Since it is on the private network, the DHCP and DNS server has no access
to repositories, nor the Internet in general. This is why it is prepared
directly from the hypervisor. As a consequence, the jenkins workers must
drop the public SSH key of their  "jenkins" user into the authorized hosts
file of the hypervisor. Or, if you are testing yourself, drop your own key.

If the hypervisor runs SLES 15 SP6 at least, you may also need to
hack sshd for it to accept RSA keys, since old versions of the
terraform libvirt provider (like 0.6.3) only work with RSA keys.

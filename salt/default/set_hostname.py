#!/usr/bin/python
import errno
import os
import re
import socket
import subprocess
import sys

if len(sys.argv) != 3:
    print("Usage: set_hostname.py <HOSTNAME> <DOMAIN>")
    sys.exit(1)

_, hostname, domain = sys.argv
fqdn = hostname + "." + domain

# set the hostname in the kernel, this is needed for Red Hat systems
# and does not hurt in others
subprocess.check_call(["sysctl", "kernel.hostname=" + hostname])

# set the hostname in userland. There is no consensus among distros
# but Debian prefers the short name, SUSE demands the short name,
# Red Hat suggests the FQDN but works with the short name.
# Bottom line: short name is used here
try:
    subprocess.check_call(["hostnamectl", "set-hostname", hostname])
except OSError as e:
    if e.errno == errno.ENOENT:
        # fallback for non-systemd systems
        subprocess.check_call(["hostname", hostname])

# set the hostname in the filesystem
with open("/etc/hostname", "w") as f:
    f.write(hostname + "\n")

# set a SUSE-specific filesystem entry
try:
    os.remove("/etc/HOSTNAME")
except OSError:
    pass
with open("/etc/HOSTNAME", "w") as f:
    f.write(fqdn + "\n")

# set the hostname and FQDN name in /etc/hosts
# this is not needed with a proper DNS server in place, meant as a workaround
# for any case in which it is not. We try to use real IP addresses in order not
# to break round-robin DNS resolution, use 127.0.1.1 as a last-effort.
# IPV6: we do not accept link-local addresses as at the moment it is difficult
# to determine their scope id (interface name) in a robust way
def guess_address(fqdn, hostname, socket_type, invalid_prefixes, default):
    infos = []
    try:
        infos += socket.getaddrinfo(fqdn, None, socket_type)
    except socket.error:
        pass
    try:
        infos += socket.getaddrinfo(hostname, None, socket_type)
    except socket.error:
        pass
    addresses = [info[4][0] for info in infos]
    valid_addresses = filter(lambda s: not re.match(invalid_prefixes, s, re.I), addresses)
    if valid_addresses:
        return valid_addresses[0]
    else:
        return default

def update_hosts_file(fqdn, hostname, repl):
    with open("/etc/hosts", "r+") as f:
        hosts = f.read()
        pattern = re.compile("\\n+(.*{0} {1}\\n+)+".format(re.escape(fqdn), re.escape(hostname)), flags=re.M)
        new_hosts, n = pattern.subn(repl, hosts)
        if n == 0:
            new_hosts = hosts + repl
        f.seek(0)
        f.truncate()
        f.write(new_hosts)

update_hosts_file(fqdn, hostname, "")
ipv4 = guess_address(fqdn, hostname, socket.AF_INET, "127\\.0\\.", "127.0.1.1")
ipv6 = guess_address(fqdn, hostname, socket.AF_INET6, "(::1$)|(fe[89ab][0-f]:)", "# ipv6 address not found for names:")
repl = "\n\n{0} {1} {2}\n{3} {4} {5}\n".format(ipv4, fqdn, hostname, ipv6, fqdn, hostname)
update_hosts_file(fqdn, hostname, repl)

print("Hostname changed.")

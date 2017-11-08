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
fqdn = "{0}.{1}".format(hostname, domain)

# set the hostname in the kernel
subprocess.check_call(["sysctl", "kernel.hostname={0}".format(fqdn)])

# set the hostname in userland
try:
    subprocess.check_call(["hostnamectl", "set-hostname", fqdn])
except OSError as e:
    if e.errno == errno.ENOENT:
        # fallback for non-systemd systems
        subprocess.check_call(["hostname", fqdn])

# set the hostname in the filesystem
with open("/etc/hostname", "w") as f:
    f.write(fqdn)
try:
    os.remove("/etc/HOSTNAME")
except OSError:
    pass
os.symlink("/etc/hostname", "/etc/HOSTNAME")

# set the hostname as a DNS name in /etc/hosts
def guess_address(fqdn, socket_type, invalid_prefix, default):
    try:
        infos = socket.getaddrinfo(fqdn, None, socket_type)
        addresses = [info[4][0] for info in infos]
        valid_addresses = filter(lambda s: not s.startswith(invalid_prefix), addresses)
        if valid_addresses:
            return valid_addresses[0]
        else:
            return default
    except socket.error:
        return default

def update_hosts_file(fqdn, hostname, repl):
    with open("/etc/hosts", "r+") as f:
        hosts = f.read()
        pattern = re.compile("\\n+(.*{0} {1}\\n+)+".format(re.escape(fqdn), re.escape(hostname)), flags=re.M)
        new_hosts, n = pattern.subn(repl, hosts)
        if n == 0:
            new_hosts = "{0}{1}".format(hosts, repl)
        f.seek(0)
        f.truncate()
        f.write(new_hosts)

update_hosts_file(fqdn, hostname, "")
ipv4 = guess_address(fqdn, socket.AF_INET, "127.0.", "127.0.1.1")
ipv6 = guess_address(fqdn, socket.AF_INET6, "::1", "# ipv6 address not found for names:")
repl = "\n\n{0} {1} {2}\n{3} {4} {5}\n".format(ipv4, fqdn, hostname, ipv6, fqdn, hostname)
update_hosts_file(fqdn, hostname, repl)

print("Hostname changed.")

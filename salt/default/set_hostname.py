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
            new_hosts = hosts + repl
        f.seek(0)
        f.truncate()
        f.write(new_hosts)

update_hosts_file(fqdn, hostname, "")
ipv4 = guess_address(hostname, socket.AF_INET, "127.0.", "127.0.1.1")
ipv6 = guess_address(hostname, socket.AF_INET6, "::1", "# ipv6 address not found for names:")
repl = "\n\n{0} {1} {2}\n{3} {4} {5}\n".format(ipv4, fqdn, hostname, ipv6, fqdn, hostname)
update_hosts_file(fqdn, hostname, repl)

print("Hostname changed.")

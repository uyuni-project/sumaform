#!/usr/bin/{{ pythonexec }}
import errno
import os
import re
import socket
import subprocess
import sys

if len(sys.argv) != 3:
    print("Usage: set_ip_in_etc_hosts.py <HOSTNAME> <DOMAIN>")
    sys.exit(1)

_, hostname, domain = sys.argv
fqdn = hostname + "." + domain

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
    valid_addresses = [item for item in addresses if not re.match(invalid_prefixes, item, re.I)]
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
# we explicitly exclude link-local addresses as we currently can't get the interface names
ipv6 = guess_address(fqdn, hostname, socket.AF_INET6, "(::1$)|(fe[89ab][0-f]:)", "# ipv6 address not found for names:")
repl = "\n\n{0} {1} {2}\n{3} {4} {5}\n".format(ipv4, fqdn, hostname, ipv6, fqdn, hostname)
update_hosts_file(fqdn, hostname, repl)

print("/etc/hosts updated.")

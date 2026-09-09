#!{{grains['pythonexecutable']}}

import os
import sys
import time

try:
    # Python 2
    from urllib2 import urlopen, HTTPError
    from xmlrpclib import Server
except ImportError:
    # Python 3
    from urllib.request import urlopen
    from urllib.error import HTTPError
    from xmlrpc.client import ServerProxy as Server

if len(sys.argv) != 5:
    print("Usage: wait_for_reposync.py <USERNAME> <PASSWORD> <MASTER FQDN> <CHANNEL>")
    sys.exit(1)

_, username, password, fqdn, channel = sys.argv

MANAGER_URL = "http://{}/rpc/api".format(fqdn)

# ensure Tomcat is up
for _ in range(10):
    try:
        urlopen(MANAGER_URL)
        break
    except HTTPError:
        time.sleep(3)

client = Server(MANAGER_URL, verbose=0)

session_key = client.auth.login(username, password)

channels = [c for c in client.channel.listVendorChannels(session_key) if c["label"] == channel]
if not channels:
    print("Channel not found.")
    sys.exit(1)

print("Waiting for reposync to finish...")

while not os.path.isfile("/var/cache/rhn/repodata/{}/repomd.xml".format(channel)):
    print("...not finished yet...")
    time.sleep(10)

print("Done.")

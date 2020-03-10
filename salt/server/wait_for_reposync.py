#!{{grains['pythonexecutable']}}

import os
import sys
import time
import urllib2
import xmlrpclib

if len(sys.argv) != 5:
    print("Usage: wait_for_reposync.py <USERNAME> <PASSWORD> <MASTER FQDN> <CHANNEL>")
    sys.exit(1)

_, username, password, fqdn, channel = sys.argv

MANAGER_URL = "http://{}/rpc/api".format(fqdn)

# ensure Tomcat is up
for _ in range(10):
    try:
        urllib2.urlopen(MANAGER_URL)
        break
    except urllib2.HTTPError:
        time.sleep(3)

client = xmlrpclib.Server(MANAGER_URL, verbose=0)

session_key = client.auth.login(username, password)

channels = filter(lambda c: c["label"] == channel, client.channel.listVendorChannels(session_key))
if not channels:
    print("Channel not found.")
    sys.exit(1)

id = channels[0]["id"]

print("Waiting for reposync to finish...")

while not os.path.isfile("/var/cache/rhn/repodata/{}/repomd.xml".format(channel)):
    print("...not finished yet...")
    time.sleep(10)

print("Done.")

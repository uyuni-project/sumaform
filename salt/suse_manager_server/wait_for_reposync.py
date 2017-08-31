#!/usr/bin/python
import sys
import time
import urllib2
import xmlrpclib

if len(sys.argv) != 5:
    print("Usage: wait_for_reposync.py <USERNAME> <PASSWORD> <MASTER FQDN> <CHANNEL>")
    sys.exit(1)

MANAGER_URL = "http://localhost/rpc/api"

# ensure Tomcat is up
for _ in range(10):
    try:
        urllib2.urlopen(MANAGER_URL)
        break
    except urllib2.HTTPError:
        time.sleep(3)

client = xmlrpclib.Server(MANAGER_URL, verbose=0)

session_key = client.auth.login(sys.argv[1], sys.argv[2])

channels = filter(lambda c: c["label"] == sys.argv[4], client.channel.listVendorChannels(session_key))
if not channels:
    print("Channel not found.")
    sys.exit(1)

id = channels[0]["id"]

print("Waiting for reposync to finish...")

while not client.channel.software.getDetails(session_key, id).get("yumrepo_last_sync"):
    time.sleep(3)

print("Done.")

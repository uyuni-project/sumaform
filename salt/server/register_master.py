#!{{grains['pythonexecutable']}}

import sys
import time
import urllib2
import xmlrpclib

if len(sys.argv) != 5:
    print("Usage: register_master.py <USERNAME> <PASSWORD> <MASTER FQDN> <SLAVE FQDN>")
    sys.exit(1)

MANAGER_URL = "http://{}/rpc/api".format(sys.argv[4])

# ensure Tomcat is up
for _ in range(10):
    try:
        urllib2.urlopen(MANAGER_URL)
        break
    except urllib2.HTTPError:
        time.sleep(3)

client = xmlrpclib.Server(MANAGER_URL, verbose=0)

session_key = client.auth.login(sys.argv[1], sys.argv[2])

try:
    previous_master = client.sync.master.getMasterByLabel(session_key, sys.argv[3])
    client.sync.master.delete(session_key, previous_master["id"])
    print("Pre-existing Master deleted.")
except:
    pass

master = client.sync.master.create(session_key, sys.argv[3])

print("Master added to this Slave.")

result = client.sync.master.makeDefault(session_key, master["id"])
if result != 1:
    print("Got error %d on makeDefault" % result)
    sys.exit(1)

print("Master made default.")

result = client.sync.master.setCaCert(session_key, master["id"], "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT")
if result != 1:
    print("Got error %d on setCaCert" % result)
    sys.exit(1)

print("CA cert path set.")

print("Done.")

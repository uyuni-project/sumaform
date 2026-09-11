#!{{grains['pythonexecutable']}}

import os
import ssl
import sys
import time
from urllib.request import urlopen
from urllib.error import HTTPError
from xmlrpc.client import ProtocolError, ServerProxy as Server

if len(sys.argv) != 5:
    print("Usage: register_slave.py <USERNAME> <PASSWORD> <MASTER FQDN> <SLAVE FQDN>")
    sys.exit(1)

MANAGER_URL = "https://{}/rpc/api".format(sys.argv[3])

SERVER_CA = "/srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT"
if not os.path.isfile(SERVER_CA):
    print("Server CA not found at {}".format(SERVER_CA))
    sys.exit(1)

ssl_context = ssl.create_default_context(cafile=SERVER_CA)
ssl_context.minimum_version = ssl.TLSVersion.TLSv1_2

# ensure Tomcat is up
for _ in range(10):
    try:
        with urlopen(MANAGER_URL, context=ssl_context, timeout=30):
            break
    except HTTPError as error:
        error.close()
        break
    except OSError:
        time.sleep(3)

client = Server(MANAGER_URL, verbose=0, context=ssl_context)

session_key = None
attempts = 10
while session_key is None and attempts > 0:
    try:
        session_key = client.auth.login(sys.argv[1], sys.argv[2])
    except ProtocolError:
        time.sleep(3)
        attempts -= 1

try:
    previous_slave = client.sync.slave.getSlaveByName(session_key, sys.argv[4])
    client.sync.slave.delete(session_key, previous_slave["id"])
    print("Pre-existing Slave deleted.")
except:
    pass

slave = client.sync.slave.create(session_key, sys.argv[4], True, True)

print("Slave added to this Master.")

orgs = client.org.listOrgs(session_key)
result = client.sync.slave.setAllowedOrgs(session_key, slave["id"], [org["id"] for org in orgs])
if result != 1:
    print("Got error %d on setAllowedOrgs" % result)
    sys.exit(1)

print("All orgs exported.")

print("Done.")

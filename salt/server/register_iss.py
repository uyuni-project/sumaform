#!{{grains['pythonexecutable']}}

import argparse
import os
import ssl
import sys
import time
from urllib.request import urlopen
from urllib.error import HTTPError
from xmlrpc.client import ProtocolError, ServerProxy as Server


parser = argparse.ArgumentParser(prog="register_iss.py", description="Register an ISS peer on the server this script runs on")
parser.add_argument("role", choices=("master", "slave"), help="which peer to register")
parser.add_argument("username", help="user name of the API user")
parser.add_argument("password", help="password of the API user")
parser.add_argument("master_fqdn", help="FQDN of the ISS master")
parser.add_argument("slave_fqdn", help="FQDN of the ISS slave")
args = parser.parse_args()

# Whichever peer gets registered, the API we talk to is the one on this host: the
# slave when registering its master, the master when registering one of its slaves.
MANAGER_URL = "https://{}/rpc/api".format(args.slave_fqdn if args.role == "master" else args.master_fqdn)

SERVER_CA = "/srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT"
MASTER_CA = "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT"

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
        session_key = client.auth.login(args.username, args.password)
    except ProtocolError:
        time.sleep(3)
        attempts -= 1

if session_key is None:
    print("Could not log in to {}".format(MANAGER_URL))
    sys.exit(1)

if args.role == "master":
    try:
        previous_master = client.sync.master.getMasterByLabel(session_key, args.master_fqdn)
        client.sync.master.delete(session_key, previous_master["id"])
        print("Pre-existing Master deleted.")
    except:
        pass

    master = client.sync.master.create(session_key, args.master_fqdn)

    print("Master added to this Slave.")

    result = client.sync.master.makeDefault(session_key, master["id"])
    if result != 1:
        print("Got error %d on makeDefault" % result)
        sys.exit(1)

    print("Master made default.")

    result = client.sync.master.setCaCert(session_key, master["id"], MASTER_CA)
    if result != 1:
        print("Got error %d on setCaCert" % result)
        sys.exit(1)

    print("CA cert path set.")
else:
    try:
        previous_slave = client.sync.slave.getSlaveByName(session_key, args.slave_fqdn)
        client.sync.slave.delete(session_key, previous_slave["id"])
        print("Pre-existing Slave deleted.")
    except:
        pass

    slave = client.sync.slave.create(session_key, args.slave_fqdn, True, True)

    print("Slave added to this Master.")

    orgs = client.org.listOrgs(session_key)
    result = client.sync.slave.setAllowedOrgs(session_key, slave["id"], [org["id"] for org in orgs])
    if result != 1:
        print("Got error %d on setAllowedOrgs" % result)
        sys.exit(1)

    print("All orgs exported.")

print("Done.")

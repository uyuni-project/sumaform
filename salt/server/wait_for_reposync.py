#!{{grains['pythonexecutable']}}

import argparse
import os
import ssl
import sys
import time
from urllib.request import urlopen
from urllib.error import HTTPError
from xmlrpc.client import ServerProxy as Server

parser = argparse.ArgumentParser(prog="wait_for_reposync.py", description="Wait for the reposync of a channel to finish")
parser.add_argument("username", help="user name of the API user")
parser.add_argument("password", help="password of the API user")
parser.add_argument("fqdn", help="FQDN of the server")
parser.add_argument("channel", help="label of the channel to wait for")
args = parser.parse_args()

MANAGER_URL = "https://{}/rpc/api".format(args.fqdn)

SERVER_CA_PATHS = [
    "/srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT",
    "/var/lib/containers/storage/volumes/srv-www/_data/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT",
]
server_ca = next((path for path in SERVER_CA_PATHS if os.path.isfile(path)), None)
if server_ca is None:
    print("Server CA not found in any of: {}".format(", ".join(SERVER_CA_PATHS)))
    sys.exit(1)

ssl_context = ssl.create_default_context(cafile=server_ca)
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

session_key = client.auth.login(args.username, args.password)

channels = [c for c in client.channel.listVendorChannels(session_key) if c["label"] == args.channel]
if not channels:
    print("Channel not found.")
    sys.exit(1)

print("Waiting for reposync to finish...")

while not os.path.isfile("/var/cache/rhn/repodata/{}/repomd.xml".format(args.channel)):
    print("...not finished yet...")
    time.sleep(10)

print("Done.")

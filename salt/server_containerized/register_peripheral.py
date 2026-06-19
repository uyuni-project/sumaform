#!/usr/bin/env python3
# Registers this peripheral server to the hub via the hub XML-RPC API.
# Rendered by Salt (file.managed template: jinja) on the peripheral minion.
import ssl
import xmlrpc.client

HUB_FQDN = "{{ hub_fqdn }}"
PERIPHERAL_FQDN = "{{ peripheral_fqdn }}"
USERNAME = "{{ server_username }}"
PASSWORD = "{{ server_password }}"
HUB_CA = "/root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT"

# Validate the hub certificate against the hub CA we already downloaded.
ctx = ssl.create_default_context(cafile=HUB_CA)
hub = xmlrpc.client.ServerProxy("https://%s/rpc/api" % HUB_FQDN, context=ctx)

session = hub.auth.login(USERNAME, PASSWORD)
try:
    with open(HUB_CA) as f:
        ca = f.read()
    hub.sync.hub.registerPeripheral(session, PERIPHERAL_FQDN, USERNAME, PASSWORD, ca)
finally:
    hub.auth.logout(session)

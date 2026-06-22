#!/usr/bin/env python3
# Idempotence check for hub_peripheral_register: exits 0 if this peripheral is
# already registered to the hub (so the registration step is skipped), 1 otherwise.
# Rendered by Salt (file.managed template: jinja) on the peripheral minion.
import ssl
import sys
import xmlrpc.client

HUB_FQDN = {{ hub_fqdn | tojson }}
PERIPHERAL_FQDN = {{ peripheral_fqdn | tojson }}
USERNAME = {{ server_username | tojson }}
PASSWORD = {{ server_password | tojson }}
HUB_CA = "/root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT"

# Validate the hub certificate against the hub CA we already downloaded.
ctx = ssl.create_default_context(cafile=HUB_CA)
hub = xmlrpc.client.ServerProxy("https://%s/rpc/api" % HUB_FQDN, context=ctx)

session = hub.auth.login(USERNAME, PASSWORD)
try:
    servers = hub.sync.hub.listPeripheralServers(session)
finally:
    hub.auth.logout(session)

sys.exit(0 if any(p.get("fqdn") == PERIPHERAL_FQDN for p in servers) else 1)

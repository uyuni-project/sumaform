#!/bin/bash
# wait_for_ip.sh <domain_name> [hypervisor_uri]
# Waits until a routable IP is visible via the QEMU agent.
# On success, writes the IP to /tmp/<domain_name>.ip for get_ip.sh to read.
# Note: --source lease is not used as bridged networks do not have libvirt-managed DHCP.

DOMAIN=$1
HYPERVISOR_URI=${2:-$LIBVIRT_DEFAULT_URI}
RETRIES=100
SLEEP_INTERVAL=10
IP_FILE="/tmp/${DOMAIN}.ip"

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain_name> [hypervisor_uri]"
    exit 1
fi

if [ -z "$HYPERVISOR_URI" ]; then
    echo "Error: No hypervisor URI provided and LIBVIRT_DEFAULT_URI is not set"
    exit 1
fi

if ! command -v virsh &>/dev/null; then
    echo "Error: virsh not found. Please install libvirt-client."
    exit 1
fi

echo "Starting wait for routable IP on domain: $DOMAIN via $HYPERVISOR_URI"

for ((i=1; i<=RETRIES; i++)); do
    AGENT_IP=$(virsh -c "$HYPERVISOR_URI" domifaddr "$DOMAIN" --source agent 2>&1 | \
         grep -E "v4|v6" | \
         grep -vE "fe80|169\.254|127\.|::1|^0\.0\.0\.0$|^::$" | \
         awk '{print $4}' | cut -d/ -f1 | head -n1)

    if [ -n "$AGENT_IP" ]; then
        echo "Success: Found routable IP $AGENT_IP"
        echo "$AGENT_IP" > "$IP_FILE"
        exit 0
    fi

    echo "[$i/$RETRIES] Waiting for routable IP for $DOMAIN..."
    sleep "$SLEEP_INTERVAL"
done

echo "Error: Timed out waiting for routable IP for $DOMAIN."
exit 1

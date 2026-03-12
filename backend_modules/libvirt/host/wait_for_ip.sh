#!/bin/bash
# wait_for_ip.sh <domain_name> [hypervisor_uri]
# If hypervisor_uri is not provided, falls back to LIBVIRT_DEFAULT_URI env variable

DOMAIN=$1
HYPERVISOR_URI=${2:-$LIBVIRT_DEFAULT_URI}
RETRIES=100
SLEEP_INTERVAL=10

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain_name> [hypervisor_uri]"
    exit 1
fi

if [ -z "$HYPERVISOR_URI" ]; then
    echo "Error: No hypervisor URI provided and LIBVIRT_DEFAULT_URI is not set"
    exit 1
fi

echo "Starting wait for routable IP on domain: $DOMAIN via $HYPERVISOR_URI"

for ((i=1; i<=RETRIES; i++)); do
    IP=$(virsh -c "$HYPERVISOR_URI" domifaddr "$DOMAIN" --source agent 2>/dev/null | \
         grep -E "v4|v6" | \
         grep -vE "fe80|169\.254" | \
         awk '{print $4}' | cut -d/ -f1 | head -n1)

    if [ -n "$IP" ]; then
        echo "Success: Found routable IP $IP"
        exit 0
    fi

    echo "[$i/$RETRIES] Waiting for routable IP for $DOMAIN..."
    sleep "$SLEEP_INTERVAL"
done

echo "Error: Timed out waiting for a routable IP address for $DOMAIN."
exit 1

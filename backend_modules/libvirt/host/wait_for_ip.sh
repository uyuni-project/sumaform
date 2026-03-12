#!/bin/bash
# wait_for_ssh.sh <domain_name> <hypervisor_uri>

DOMAIN=$1
HYPERVISOR_URI=$2
RETRIES=100
SLEEP_INTERVAL=10

if [ -z "$DOMAIN" ] || [ -z "$HYPERVISOR_URI" ]; then
    echo "Usage: $0 <domain_name> <hypervisor_uri>"
    exit 1
fi

echo "Waiting for routable IP on domain: $DOMAIN via $HYPERVISOR_URI"

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

echo "Error: Timed out waiting for routable IP for $DOMAIN"
exit 1
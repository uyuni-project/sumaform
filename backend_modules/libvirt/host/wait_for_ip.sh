#!/bin/bash
# wait_for_ip.sh <domain_name>

DOMAIN=$1
RETRIES=100
SLEEP_INTERVAL=10

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain_name>"
    exit 1
fi

echo "Starting wait for routable IP on domain: $DOMAIN"

for ((i=1; i<=RETRIES; i++)); do
    # 1. Get addresses via QEMU agent
    # 2. Filter out fe80 (IPv6 Link-Local) and 169.254 (IPv4 APIPA)
    # 3. Extract the first valid IP
    IP=$(virsh domifaddr "$DOMAIN" --source agent 2>/dev/null | \
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
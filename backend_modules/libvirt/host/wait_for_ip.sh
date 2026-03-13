#!/bin/bash
## wait_for_ip.sh <domain_name> [hypervisor_uri]
## Waits until a routable IP is visible via BOTH the QEMU agent AND the libvirt
## lease table (which is what Terraform state reads from wait_for_lease=true).

DOMAIN=$1
HYPERVISOR_URI=${2:-$LIBVIRT_DEFAULT_URI}
RETRIES=50
SLEEP_INTERVAL=5

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
    ## Check via QEMU agent (what we confirmed working)
    AGENT_IP=$(virsh -c "$HYPERVISOR_URI" domifaddr "$DOMAIN" --source agent 2>&1 | \
         grep -E "v4|v6" | \
         grep -vE "fe80|169\.254|127\.|::1|^0\.0\.0\.0$|^::$" | \
         awk '{print $4}' | cut -d/ -f1 | head -n1)

    if [ -z "$AGENT_IP" ]; then
        echo "[$i/$RETRIES] Agent: no routable IP yet for $DOMAIN..."
        sleep "$SLEEP_INTERVAL"
        continue
    fi

    ## Also check via lease (what Terraform state reads via wait_for_lease=true)
    LEASE_IP=$(virsh -c "$HYPERVISOR_URI" domifaddr "$DOMAIN" --source lease 2>&1 | \
         grep -E "v4|v6" | \
         grep -vE "fe80|169\.254|127\.|::1|^0\.0\.0\.0$|^::$" | \
         awk '{print $4}' | cut -d/ -f1 | head -n1)

    if [ -n "$LEASE_IP" ]; then
        echo "Success: Agent IP=$AGENT_IP, Lease IP=$LEASE_IP - Terraform state should be ready"
        exit 0
    fi

    echo "[$i/$RETRIES] Agent has IP ($AGENT_IP) but lease not yet visible for $DOMAIN..."
    sleep "$SLEEP_INTERVAL"
done

echo "Error: Timed out waiting for routable IP for $DOMAIN."
exit 1

#!/bin/bash
# wait_for_ip.sh <domain_name> [hypervisor_uri]
# Waits until a routable IP is visible via the QEMU agent.
# Returns JSON {"ip": "x.x.x.x"} for use with Terraform data "external" source.
# Note: --source lease is not used as bridged networks do not have libvirt-managed DHCP.

DOMAIN=$1
HYPERVISOR_URI=${2:-$LIBVIRT_DEFAULT_URI}
RETRIES=100
SLEEP_INTERVAL=10

if [ -z "$DOMAIN" ]; then
    echo "Error: domain name is required" >&2
    exit 1
fi

if [ -z "$HYPERVISOR_URI" ]; then
    echo "Error: No hypervisor URI provided and LIBVIRT_DEFAULT_URI is not set" >&2
    exit 1
fi

if ! command -v virsh &>/dev/null; then
    echo "Error: virsh not found. Please install libvirt-client." >&2
    exit 1
fi

echo "Starting wait for routable IP on domain: $DOMAIN via $HYPERVISOR_URI" >&2

for ((i=1; i<=RETRIES; i++)); do
    AGENT_IP=$(virsh -c "$HYPERVISOR_URI" domifaddr "$DOMAIN" --source agent 2>&1 | \
        awk '/ipv4|ipv6/ {print $4}' | \
        cut -d/ -f1 | \
        grep -Ev '^fe80:|^169\.254\.|^127\.|^::1$|^10\.89\.|^192\.168\.' | \
        head -n1)

    if [ -n "$AGENT_IP" ]; then
        echo "Success: Found routable IP $AGENT_IP" >&2
        # Return JSON to stdout for Terraform data external
        echo "{\"ip\": \"${AGENT_IP}\"}"
        exit 0
    fi

    echo "[$i/$RETRIES] Waiting for routable IP for $DOMAIN..." >&2
    sleep "$SLEEP_INTERVAL"
done

echo "Error: Timed out waiting for routable IP for $DOMAIN." >&2
exit 1

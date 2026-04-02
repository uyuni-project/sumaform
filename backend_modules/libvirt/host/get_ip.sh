#!/bin/bash
# get_ip.sh <domain_name>
# Reads the IP written by wait_for_ip.sh and returns it as JSON.
# Called by Terraform "data external" source after wait_for_ip completes.

DOMAIN=$1
IP_FILE="/tmp/${DOMAIN}.ip"

if [ -z "$DOMAIN" ]; then
    echo "{\"ip\": \"\"}"
    exit 1
fi

if [ ! -f "$IP_FILE" ]; then
    echo "Error: IP file not found at $IP_FILE" >&2
    exit 1
fi

IP=$(tr -d '[:space:]' < "$IP_FILE")

if [ -z "$IP" ]; then
    echo "Error: IP file is empty at $IP_FILE" >&2
    exit 1
fi

echo "{\"ip\": \"${IP}\"}"

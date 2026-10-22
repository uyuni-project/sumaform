#!/bin/bash
# Pods on RKE2 resolve names through CoreDNS, which cannot query avahi (mDNS).
# Resolve the testsuite hosts here and give them to CoreDNS on each RKE2 node
# as a HelmChartConfig manifest, applied by RKE2 at startup or right away.
{%- set domain = grains['domain'] %}
{%- set hosts = [] %}
{%- for key, value in grains.items() | sort %}
{%- if value is string and value.endswith('.' ~ domain) and value not in hosts %}
{%- do hosts.append(value) %}
{%- endif %}
{%- endfor %}
set -e

MANIFEST=$(mktemp)
trap 'rm -f "$MANIFEST"' EXIT
SSH_OPTS="-i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

cat > "$MANIFEST" <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-coredns
  namespace: kube-system
spec:
  valuesContent: |-
    extraConfig:
      import:
        parameters: /etc/coredns/sumaform-avahi.server
    zoneFiles:
      - filename: sumaform-avahi.server
        domain: {{ domain }}
        contents: |
          {{ domain }}:53 {
              errors
              hosts {
EOF

for host in {{ hosts | join(' ') }}; do
  ip=$(getent ahostsv4 "$host" | awk 'NR==1 {print $1}')
  if [ -z "$ip" ]; then
    echo "WARNING: cannot resolve $host, not adding it to CoreDNS" >&2
    continue
  fi
  echo "                  $ip $host" >> "$MANIFEST"
done

cat >> "$MANIFEST" <<EOF
              }
          }
EOF

for node in {{ grains['kubernetes_dns_nodes'] | join(' ') }}; do
  ssh $SSH_OPTS "root@$node" mkdir -p /var/lib/rancher/rke2/server/manifests
  scp $SSH_OPTS "$MANIFEST" "root@$node:/var/lib/rancher/rke2/server/manifests/sumaform-avahi-coredns.yaml"
done

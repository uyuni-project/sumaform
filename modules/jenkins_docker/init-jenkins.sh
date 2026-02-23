#!/bin/bash
# init-jenkins.sh
# Run this once after the first "docker compose up -d jenkins".
# It will:
#   1. Wait for Jenkins to be ready
#   2. Extract the agent secret from the container logs and update .env
#   3. Generate an API token via the REST API and print it
#   4. Start the full stack (nginx + opensuse-worker)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# ── Load .env ─────────────────────────────────────────────────────────────
if [[ ! -f "${ENV_FILE}" ]]; then
    echo "ERROR: .env file not found at ${ENV_FILE}"
    echo "       Copy .env.example to .env and fill in your values first."
    exit 1
fi

set -a
source "${ENV_FILE}"
set +a

JENKINS_USER="${JENKINS_ADMIN_ID:-maxime}"
JENKINS_PASS="${JENKINS_ADMIN_PASSWORD:-linux}"
JENKINS_TOKEN_NAME="${JENKINS_API_TOKEN_NAME:-automation-token}"

# ── Step 1: Wait for Jenkins to be ready ─────────────────────────────────
echo ""
echo ">>> Step 1: Waiting for Jenkins to be ready..."
MAX_WAIT=120
WAITED=0
until docker exec jenkins-controller curl -sf http://localhost:8080/login > /dev/null 2>&1; do
    if [[ ${WAITED} -ge ${MAX_WAIT} ]]; then
        echo "ERROR: Jenkins did not become ready after ${MAX_WAIT}s."
        echo "       Check logs: docker logs jenkins-controller"
        exit 1
    fi
    echo "    Not ready yet... (${WAITED}s elapsed)"
    sleep 5
    WAITED=$((WAITED + 5))
done
echo "    Jenkins is up!"

# ── Step 2: Extract agent secret from logs and update .env ───────────────
echo ""
echo ">>> Step 2: Extracting agent secret from container logs..."

AGENT_SECRET=$(docker logs jenkins-controller 2>&1 \
    | grep "AGENT SECRET" \
    | sed 's/.*AGENT SECRET : //' \
    | tr -d '║' \
    | tr -d ' ')

if [[ -z "${AGENT_SECRET}" ]]; then
    echo "ERROR: Could not find agent secret in logs."
    echo "       Make sure 02-setup-agent.groovy ran successfully:"
    echo "       docker logs jenkins-controller 2>&1 | grep -A2 'AGENT SECRET'"
    exit 1
fi

echo "    Found agent secret: ${AGENT_SECRET:0:16}..."

# Update or add AGENT_SECRET in .env
if grep -q "^AGENT_SECRET=" "${ENV_FILE}"; then
    sed -i "s|^AGENT_SECRET=.*|AGENT_SECRET=${AGENT_SECRET}|" "${ENV_FILE}"
    echo "    Updated AGENT_SECRET in .env"
else
    echo "AGENT_SECRET=${AGENT_SECRET}" >> "${ENV_FILE}"
    echo "    Added AGENT_SECRET to .env"
fi

# ── Step 3: Generate API token via REST API ───────────────────────────────
echo ""
echo ">>> Step 3: Generating API token for user '${JENKINS_USER}'..."

# Use a cookie jar to maintain session across curl calls — crumb must be used
# in the same session it was generated in, or Jenkins rejects it with 403.
TOKEN_JSON=$(docker exec jenkins-controller bash -c "
  # Get crumb and save session cookie
  CRUMB=\$(curl -sf -c /tmp/jenkins-cookies -u '${JENKINS_USER}:${JENKINS_PASS}' \
    'http://localhost:8080/crumbIssuer/api/json' \
    | python3 -c 'import sys,json; print(json.load(sys.stdin)[\"crumb\"])')

  # Generate token using the same session
  curl -sf -b /tmp/jenkins-cookies -u '${JENKINS_USER}:${JENKINS_PASS}' \
    -H \"Jenkins-Crumb: \${CRUMB}\" \
    -X POST \
    'http://localhost:8080/user/${JENKINS_USER}/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' \
    --data 'newTokenName=${JENKINS_TOKEN_NAME}'

  rm -f /tmp/jenkins-cookies
")

if [[ -z "${TOKEN_JSON}" ]]; then
    echo "ERROR: Failed to generate API token. Check credentials in .env."
    exit 1
fi

API_TOKEN=$(echo "${TOKEN_JSON}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['tokenValue'])")

if [[ -z "${API_TOKEN}" ]]; then
    echo "ERROR: Could not parse token from response: ${TOKEN_JSON}"
    exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  API Token generated successfully!                       ║"
echo "║  User      : ${JENKINS_USER}"
echo "║  Token name: ${JENKINS_TOKEN_NAME}"
echo "║  Token     : ${API_TOKEN}"
echo "║                                                          ║"
echo "║  Save this value — it will NOT be shown again.          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ── Step 4: Start the full stack ──────────────────────────────────────────
echo ">>> Step 4: Starting full stack (nginx + opensuse-worker)..."
docker compose --env-file "${ENV_FILE}" up -d

echo ""
echo ">>> Done! Jenkins is available at https://maxime-poc-host.mgr.suse.de"
echo "    Login: ${JENKINS_USER} / ${JENKINS_PASS}"
echo "    API token saved above — store it somewhere safe."
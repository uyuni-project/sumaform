# Jenkins Docker Deployment

Fully automated Jenkins LTS deployment with HTTPS, pre-configured agents, jobs, and credentials—ready to use in minutes.

---

## Features

### Core Infrastructure
- **HTTPS via Nginx reverse proxy** with TLS certificate support
- **Jenkins LTS with Java 21** running in Docker
- **openSUSE Leap 15.6 JNLP build agent** with Docker-in-Docker support
- **Zero-touch setup** — no manual configuration required

### Automated Configuration
- ✅ **Admin user** created automatically on first boot (no setup wizard)
- ✅ **API token** generated via REST API after initialization
- ✅ **Build agent** registered and connected automatically
- ✅ **Jenkins URL** configured for webhook callbacks
- ✅ **Pipeline jobs** created from GitHub repositories
- ✅ **Credentials** auto-loaded from mounted secret files
- ✅ **60+ plugins** pre-installed at build time

### Advanced Features
- **Configuration as Code (JCasC)** support for declarative config
- **Healthcheck-based startup** — dependent containers wait for Jenkins to be fully ready
- **Memory limits** configured to prevent swap warnings
- **Session-aware token generation** — crumb validation handled correctly

---

## Architecture

```
┌─────────────────┐
│   Nginx Proxy   │  :443 (HTTPS) → :80 (HTTP redirect)
│  (TLS Termination)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Jenkins Controller│  :8080 (Web UI)
│    (Master)     │  :50000 (JNLP agent port)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ openSUSE Agent  │  Labels: opensuse, opensuse-15.6, sumaform-cucumber
│  (Worker Node)  │  Executors: 2
└─────────────────┘
```

---

## Folder Structure

```
jenkins_docker/
├── Dockerfile                               # Jenkins controller image
├── Dockerfile.opensuse-worker               # openSUSE Leap 15.6 agent image
├── Dockerfile.opensuse-worker-tumbleweed    # openSUSE Tumbleweed agent (optional)
├── docker-compose.yml                       # Orchestration file
├── nginx.conf                               # Nginx reverse proxy config (HTTPS)
├── jenkins.yaml                             # JCasC configuration
├── init-jenkins.sh                          # First-boot automation script
├── .env.example                             # Environment template — copy to .env
├── .gitignore
├── init.groovy.d/                           # Auto-run Groovy scripts on first boot
│   ├── 01-create-admin-user.groovy          # Creates admin user + security realm
│   ├── 02-setup-agent.groovy                # Registers JNLP agent node
│   ├── 03-configure-jenkins-url.groovy      # Sets public Jenkins URL
│   ├── 04-create-jobs.groovy                # Creates pipeline jobs from GitHub
│   └── 05-add-credentials.groovy            # Loads credentials from mounted file
├── secrets/                                 # Secret files (not in git)
│   └── .credentials                         # Sumaform secrets (mounted read-only)
├── certs/                                   # TLS certificate + key (not in git)
│   ├── jenkins.crt
│   └── jenkins.key
├── jenkins_home/                            # Persistent Jenkins data (not in git)
└── workspace/                               # Agent workspace (not in git)
```

---

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- TLS certificate and key (or generate self-signed)
- Secret files prepared (if using credential auto-loading)

### Step 1 — Prepare Environment

```bash
# Copy and edit the environment file
cp .env.example .env
chmod 600 .env

# Edit .env with your values:
# - JENKINS_ADMIN_ID
# - JENKINS_ADMIN_PASSWORD
# - JENKINS_API_TOKEN_NAME
# - JENKINS_AGENT_NAME
# - JENKINS_URL_PUBLIC

# Create required directories
mkdir -p jenkins_home workspace certs secrets

# Place your TLS certificate and key in certs/
# Self-signed example (replace with real certs for production):
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/jenkins.key \
  -out certs/jenkins.crt \
  -subj "/CN=jenkins.mgr.suse.de"

# (Optional) Add credentials file for auto-loading
cp /path/to/your/.credentials secrets/.credentials
chmod 600 secrets/.credentials
```

### Step 2 — Start Jenkins Controller

```bash
# Start only the controller (nginx and agent will start after init)
docker compose up -d jenkins
```

### Step 3 — Run Initialization Script

Wait ~30 seconds for Jenkins to start, then:

```bash
bash init-jenkins.sh
```

**The script will:**
1. Wait for Jenkins to be fully ready
2. Extract the agent secret from container logs
3. Update `.env` with `AGENT_SECRET`
4. Generate an API token via REST API
5. Display the API token (save it — it won't be shown again)
6. Start the full stack (nginx + opensuse-worker)

### Step 4 — Access Jenkins

Open your browser and navigate to:
```
https://jenkins.mgr.suse.de
```

Login with the credentials from your `.env` file.

---

## Subsequent Deployments

Once `.env` has `AGENT_SECRET` populated, you can start everything directly:

```bash
docker compose up -d --build
```

No need to run `init-jenkins.sh` again unless you perform a full reset.

---

## Configuration

### Environment Variables (.env)

| Variable | Default                       | Description |
|----------|-------------------------------|-------------|
| `JENKINS_ADMIN_ID` | `user`                        | Admin username |
| `JENKINS_ADMIN_PASSWORD` | `password`                    | Admin password |
| `JENKINS_API_TOKEN_NAME` | `automation-token`            | Name for generated API token |
| `JENKINS_AGENT_NAME` | `opensuse-agent`              | Agent node name |
| `JENKINS_URL_PUBLIC` | `https://jenkins.mgr.suse.de` | Public Jenkins URL |
| `AGENT_SECRET` | *(auto-generated)*            | JNLP agent authentication secret |

### Plugins

The following plugins are pre-installed at build time:

#### Core Plugins
- `git`, `git-client`, `github`, `github-api`, `github-branch-source`
- `credentials`, `credentials-binding`, `ssh-credentials`, `plain-credentials`
- `workflow-aggregator` (Pipeline suite)
- `matrix-auth`, `ldap`
- `configuration-as-code` (JCasC)
- `job-dsl` (Job DSL)

#### Build & SCM
- `gradle`, `ant`, `maven-plugin`
- `pipeline-model-definition`, `pipeline-stage-view`
- `branch-api`, `scm-api`

#### UI/UX
- `dark-theme`, `theme-manager`
- `greenballs` (green success indicators)
- `uno-choice` (Active Choices parameters)
- `rebuild` (rebuild last build)
- `timestamper`

#### Utilities
- `ws-cleanup` (workspace cleanup)
- `build-timeout`
- `email-ext`, `mailer`
- `metrics`

**To add plugins:**  
Edit the `RUN jenkins-plugin-cli` line in `Dockerfile` and rebuild:
```bash
docker compose build --no-cache jenkins
```

---

## Automation Scripts (init.groovy.d/)

Scripts run in alphabetical order on first boot only (when `jenkins_home/` is empty):

### 01-create-admin-user.groovy
- Creates admin user from `JENKINS_ADMIN_ID` and `JENKINS_ADMIN_PASSWORD`
- Configures global matrix authorization
- Allows anonymous read access
- Bypasses setup wizard

### 02-setup-agent.groovy
- Registers a JNLP agent node (`opensuse-agent` by default)
- Sets executor count to 2
- Assigns labels: `sumaform-cucumber`, `opensuse`, `opensuse-15.6`
- Prints agent secret to logs (captured by `init-jenkins.sh`)

### 03-configure-jenkins-url.groovy
- Sets the Jenkins URL from `JENKINS_URL_PUBLIC`
- Required for webhook callbacks and email notifications

### 04-create-jobs.groovy
- Creates a pipeline job: `manager-qe-continuous-build-validation-NUE`
- Clones from `https://github.com/SUSE/susemanager-ci.git`
- Uses `Jenkinsfile` from SCM path: `jenkins_pipelines/environments/build-validation/...`

### 05-add-credentials.groovy
- Auto-loads credentials from `/var/jenkins_home/secrets/.credentials`
- Creates a **Secret Text** credential with ID `sumaform-secrets`
- Skips if file doesn't exist (no error)

---

## Healthcheck & Startup Order

The deployment uses Docker healthchecks to ensure proper startup order:

1. **Jenkins controller** starts first and runs healthcheck:
   ```bash
   curl -sf http://localhost:8080/login || exit 1
   ```
    - Interval: 15s
    - Timeout: 10s
    - Retries: 8
    - Start period: 60s

2. **Nginx** waits for Jenkins healthcheck to pass before starting
3. **opensuse-worker** waits for Jenkins healthcheck to pass before connecting

This prevents "502 Bad Gateway" errors and agent connection failures.

---

## Memory Configuration

The worker container has memory limits to prevent swap warnings:

```yaml
mem_limit: 2g          # 2GB RAM
memswap_limit: 3g      # 2GB RAM + 1GB swap
```

Adjust these values in `docker-compose.yml` based on your workload.

---

## Useful Commands

### View Logs

```bash
# View startup output (init.groovy.d execution, agent secret)
docker logs jenkins-controller

# Follow live logs
docker logs -f jenkins-controller

# View agent logs
docker logs opensuse-worker

# View nginx logs
docker logs jenkins-proxy
```

### Container Management

```bash
# Check all containers are running
docker compose ps

# Restart a specific service
docker compose restart jenkins

# Rebuild images after Dockerfile changes
docker compose build --no-cache

# Stop everything (data preserved in jenkins_home/)
docker compose down

# Stop and remove volumes (WARNING: deletes all data)
docker compose down -v
```

### Debugging

```bash
# Execute commands inside Jenkins controller
docker exec -it jenkins-controller bash

# Check agent connectivity
docker exec jenkins-controller curl -sf http://localhost:8080/computer/opensuse-agent/

# View init.groovy.d script output
docker logs jenkins-controller 2>&1 | grep "^---"

# Extract agent secret manually
docker logs jenkins-controller 2>&1 | grep "AGENT SECRET"
```

---

## Full Reset

To completely reset Jenkins and start fresh:

```bash
# Stop all containers
docker compose down

# Remove ALL Jenkins data (including dotfiles)
sudo rm -rf jenkins_home/{*,.*} 2>/dev/null || true

# Clear the agent secret from .env
sed -i '/^AGENT_SECRET=/d' .env

# Restart from Step 2 of Quick Start
docker compose up -d jenkins
bash init-jenkins.sh
```

**Important:** Using `rm -rf jenkins_home/*` is **not sufficient** — it leaves dotfiles like `.cache`, `.java`, and `.lastStarted`, which prevent init scripts from re-running. Always use the `{*,.*}` pattern.

---

## Troubleshooting

### Agent won't connect

**Symptoms:**
- Agent container restarts repeatedly
- Logs show: "Failed to connect to http://jenkins:8080"

**Solution:**
```bash
# Check if AGENT_SECRET is set in .env
grep AGENT_SECRET .env

# If missing, run init-jenkins.sh
bash init-jenkins.sh

# Or extract manually from logs
docker logs jenkins-controller 2>&1 | grep "AGENT SECRET"
```

### "Free Swap Space is 0" warning

**Solution:**  
This is already fixed via `memswap_limit` in `docker-compose.yml`. If you still see this warning:
- Increase `memswap_limit` value
- Or disable the warning in Jenkins: Manage Jenkins → System → Monitoring → Uncheck "Free Swap Space"

### 502 Bad Gateway on first access

**Cause:** Nginx started before Jenkins was ready

**Solution:**  
This is already fixed via healthcheck dependencies. If it still occurs:
```bash
# Restart nginx after Jenkins is fully up
docker compose restart nginx
```

### Plugins not installing

**Symptoms:**
- Groovy scripts fail with `NoClassDefFoundError`
- UI missing features

**Solution:**
```bash
# Rebuild with fresh plugin download
docker compose build --no-cache jenkins
docker compose up -d jenkins
```

### Init scripts not running on fresh deployment

**Cause:** Leftover files in `jenkins_home/` from previous deployment

**Solution:**
```bash
# Perform a full reset (see Full Reset section)
sudo rm -rf jenkins_home/{*,.*} 2>/dev/null || true
```

---

## Security Considerations

### Production Checklist

- [ ] Use a real TLS certificate (not self-signed)
- [ ] Change default admin credentials in `.env`
- [ ] Set `chmod 600` on `.env` and `secrets/.credentials`
- [ ] Add `.env` and `secrets/` to `.gitignore` (already included)
- [ ] Disable anonymous read access (edit `01-create-admin-user.groovy`)
- [ ] Enable CSRF protection (enabled by default)
- [ ] Configure firewall rules (allow only 443, block 8080 and 50000 externally)
- [ ] Set up automated backups of `jenkins_home/`
- [ ] Review and minimize plugin list
- [ ] Enable audit logging
- [ ] Configure LDAP/SSO if available

### Credential Management

Credentials are stored in three ways:

1. **Admin password:** `.env` file (mounted as environment variable)
2. **Agent secret:** Auto-generated and stored in `.env`
3. **Job credentials:** Mounted from `secrets/.credentials` (auto-loaded by `05-add-credentials.groovy`)

For production:
- Use Jenkins credential providers (HashiCorp Vault, AWS Secrets Manager)
- Rotate API tokens regularly
- Use SSH keys instead of passwords where possible

---

## Customization

### Adding Custom Jobs

Edit `init.groovy.d/04-create-jobs.groovy`:

```groovy
def jobName = 'my-new-pipeline'
def job = instance.createProject(WorkflowJob.class, jobName)
def scm = new GitSCM('https://github.com/myorg/myrepo.git')
scm.branches = [new BranchSpec('*/main')]
def definition = new CpsScmFlowDefinition(scm, 'Jenkinsfile')
job.setDefinition(definition)
job.save()
```

### Adding More Agents

1. Create a new Dockerfile (e.g., `Dockerfile.ubuntu-agent`)
2. Add service to `docker-compose.yml`:
   ```yaml
   ubuntu-worker:
     build:
       dockerfile: Dockerfile.ubuntu-agent
     environment:
       - JENKINS_AGENT_NAME=ubuntu-agent
       - JENKINS_SECRET=${UBUNTU_AGENT_SECRET}
   ```
3. Duplicate `02-setup-agent.groovy` for the new agent
4. Run `init-jenkins.sh` to capture the new secret

### Using JCasC for Advanced Config

The `jenkins.yaml` file supports full JCasC configuration:

```yaml
jenkins:
  systemMessage: "Production Jenkins - Handle with Care"
  numExecutors: 0
  securityRealm:
    ldap:
      configurations:
        - server: "ldap.example.com"
          rootDN: "dc=example,dc=com"
  authorizationStrategy:
    projectMatrix:
      permissions:
        - "Overall/Administer:admin-group"
        - "Overall/Read:authenticated"
```

Changes take effect after container restart.

---

## API Access

Use the generated API token for programmatic access:

```bash
# Store the token from init-jenkins.sh output
JENKINS_USER="maxime"
JENKINS_TOKEN="your-api-token-here"
JENKINS_URL="https://jenkins.mgr.suse.de"

# Trigger a build
curl -X POST "$JENKINS_URL/job/my-job/build" \
  --user "$JENKINS_USER:$JENKINS_TOKEN"

# Get job status
curl "$JENKINS_URL/job/my-job/lastBuild/api/json" \
  --user "$JENKINS_USER:$JENKINS_TOKEN"
```

---

## Backup & Restore

### Backup

```bash
# Stop Jenkins to ensure consistency
docker compose stop jenkins

# Create timestamped backup
tar -czf jenkins-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  jenkins_home/ \
  .env \
  secrets/

# Restart Jenkins
docker compose start jenkins
```

### Restore

```bash
# Stop all services
docker compose down

# Extract backup
tar -xzf jenkins-backup-20250224-120000.tar.gz

# Start services
docker compose up -d
```

For production, use volume backups or cloud-native backup solutions.

---

## License

This configuration is provided as-is for internal use. Refer to individual component licenses:
- Jenkins: [MIT License](https://github.com/jenkinsci/jenkins/blob/master/LICENSE.txt)
- Nginx: [2-clause BSD License](http://nginx.org/LICENSE)
- openSUSE: [Various open source licenses](https://www.opensuse.org/)

---

## Support & Contribution

For issues or improvements:
1. Check the Troubleshooting section above
2. Review Docker logs: `docker logs jenkins-controller`
3. Consult [Jenkins documentation](https://www.jenkins.io/doc/)
4. Open an issue in your internal repository

---

## Changelog

### v2.0 (Current)
- Added healthcheck-based startup order
- Implemented session-aware API token generation
- Added credential auto-loading from mounted files
- Configured memory limits for swap warning fix
- Added 5 auto-configuration scripts (init.groovy.d/)
- Pre-installed 60+ plugins at build time

### v1.0 (Initial)
- Basic Jenkins + Nginx deployment
- Manual setup wizard required
- Single openSUSE agent
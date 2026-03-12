# Use the official Jenkins LTS image with Java 21
FROM jenkins/jenkins:lts-jdk21

USER root

# Install docker CLI so Jenkins can interact with the host Docker socket
RUN apt-get update && \
    apt-get install -y docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add jenkins user to docker group (socket is mounted via compose)
RUN usermod -aG docker jenkins

USER jenkins

# Pre-install plugins at build time - must be on a single line
# Plugins from working Jenkins + additional required plugins
RUN jenkins-plugin-cli --latest --latest-specified --plugins "ant antisamy-markup-formatter apache-httpcomponents-client-4-api asm-api bootstrap5-api bouncycastle-api branch-api build-timeout caffeine-api checks-api cloudbees-folder commons-lang3-api commons-text-api credentials-binding credentials dark-theme display-url-api durable-task echarts-api eddsa-api email-ext font-awesome-api git-client git github-api github-branch-source github gradle gson-api instance-identity ionicons-api jackson2-api jakarta-activation-api jakarta-mail-api jakarta-xml-bind-api javax-activation-api jaxb jjwt-api joda-time-api jquery3-api json-api json-path-api jsoup junit ldap mailer matrix-auth matrix-project metrics mina-sshd-api-common mina-sshd-api-core okhttp-api pipeline-build-step pipeline-github-lib pipeline-graph-view pipeline-groovy-lib pipeline-input-step pipeline-milestone-step pipeline-model-api pipeline-model-definition pipeline-model-extensions pipeline-stage-step pipeline-stage-tags-metadata plain-credentials plugin-util-api prism-api resource-disposer scm-api script-security snakeyaml-api ssh-credentials ssh-slaves structs theme-manager timestamper token-macro trilead-api variant workflow-aggregator workflow-api workflow-basic-steps workflow-cps workflow-durable-task-step workflow-job workflow-multibranch workflow-scm-step workflow-step-api workflow-support ws-cleanup uno-choice pipeline-stage-view greenballs configuration-as-code job-dsl rebuild"

# Do NOT override ENTRYPOINT — Jenkins' own entrypoint (/usr/bin/tini + jenkins.sh)
# is responsible for loading init.groovy.d scripts and plugins correctly.
EXPOSE 8080 50000

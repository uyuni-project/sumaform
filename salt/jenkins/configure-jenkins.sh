#!/bin/bash

URL="http://localhost:8080"

RETRIES=0
while [ "$(curl -s -o /dev/null -w %{http_code} ${URL})" != "200" -a ${RETRIES} -lt 10 ]; do
   sleep 10
   RETRIES=$((RETRIES+1))
done

echo "[INFO] Downloading ${URL}/jnlpJars/jenkins-cli.jar"
curl -s ${URL}/jnlpJars/jenkins-cli.jar -o /tmp/jenkins-cli.jar
if [ ${?} -ne 0 ]; then
   echo "[ERROR] Could not download ${URL}/jnlpJars/jenkins-cli.jar"
   exit 1
fi

cli_call() {
  echo "[INFO] Running CLI call with arguments: ${@}"
  java -jar /tmp/jenkins-cli.jar -s ${URL} -auth admin:"$(cat /var/lib/jenkins/secrets/initialAdminPassword)" ${@}
}

# Only credential 2.6.1 is compatible with current LTS 2.303.3
# For some reason using URL breaks the command if it's reapplied, so be sure
# you removed credentials from thos command if you want to reapply
cli_call install-plugin swarm https://updates.jenkins.io/download/plugins/credentials/2.6.1/credentials.hpi git git-client workflow-aggregator copyartifact extended-choice-parameter timestamper htmlpublisher rebuild http_request ansicolor greenballs -deploy -restart


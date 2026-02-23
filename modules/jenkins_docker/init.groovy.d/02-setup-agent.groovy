// init.groovy.d/02-setup-agent.groovy
// Registers a persistent JNLP agent node so the opensuse-worker container
// can connect without any manual configuration in the UI.

import jenkins.model.*
import hudson.model.*
import hudson.slaves.*

def instance     = Jenkins.get()
def agentName    = System.getenv('JENKINS_AGENT_NAME') ?: 'opensuse-agent'
def remoteFs     = '/home/jenkins/workspace'

if (instance.getNode(agentName) != null) {
    println "--- Agent '${agentName}' already registered, skipping."
    return
}

// JNLPLauncher() with no args is the correct signature in Jenkins 2.x+
// (the boolean constructor was removed; workDirSettings are passed separately)
def launcher = new JNLPLauncher()

DumbSlave agent = new DumbSlave(
    agentName,
    remoteFs,
    launcher
)
agent.setNumExecutors(2)
agent.setMode(Node.Mode.NORMAL)
agent.setRetentionStrategy(new RetentionStrategy.Always())
agent.setNodeDescription("openSUSE Leap 15.6 build agent")
agent.setLabelString("sumaform-cucumber opensuse opensuse-15.6")

instance.addNode(agent)
instance.save()

// Print the agent secret so it can be captured from docker logs or passed via .env
def secret = instance.getLabelAtom(agentName)
def computer = instance.getComputer(agentName)
if (computer instanceof hudson.slaves.SlaveComputer) {
    println '╔══════════════════════════════════════════════════════════╗'
    println "║  Agent registered: ${agentName.padRight(38)}║"
    println "║  AGENT SECRET : ${computer.getJnlpMac().padRight(41)}║"
    println '║  Set AGENT_SECRET in your .env file with this value.    ║'
    println '╚══════════════════════════════════════════════════════════╝'
} else {
    println "--- Agent '${agentName}' registered. Retrieve secret from Jenkins UI: Manage Jenkins → Nodes → ${agentName}."
}

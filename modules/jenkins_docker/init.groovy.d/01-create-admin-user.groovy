import jenkins.model.Jenkins
import jenkins.install.InstallState
import hudson.security.HudsonPrivateSecurityRealm
import hudson.security.GlobalMatrixAuthorizationStrategy

def instance = Jenkins.get()

def userId       = System.getenv('JENKINS_ADMIN_ID')       ?: 'maxime'
def userPassword = System.getenv('JENKINS_ADMIN_PASSWORD') ?: 'linux'

def realm = new HudsonPrivateSecurityRealm(false)
realm.createAccount(userId, userPassword)
instance.setSecurityRealm(realm)

def strategy = new GlobalMatrixAuthorizationStrategy()
strategy.add(Jenkins.ADMINISTER, userId)
strategy.add(Jenkins.READ, 'anonymous')
instance.setAuthorizationStrategy(strategy)

if (!instance.installState.isSetupComplete()) {
    println '--- Bypassing Jenkins Setup Wizard ---'
    instance.installState = InstallState.INITIAL_SETUP_COMPLETED
}

instance.save()
println "--- Admin user '${userId}' created successfully."
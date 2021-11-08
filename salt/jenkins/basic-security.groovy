#!groovy

import jenkins.model.*
import hudson.security.*
import static jenkins.model.Jenkins.instance as jenkins
import jenkins.install.InstallState

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
String randomPassword = org.apache.commons.lang.RandomStringUtils.randomAscii(30)

println "Writing the password to /var/lib/jenkins/secrets/initialAdminPassword"
File file = new File("/var/lib/jenkins/secrets/initialAdminPassword")
file.write randomPassword + "\n"

println "Creating the user 'admin"
hudsonRealm.createAccount('admin',randomPassword)

println "Enabling the integrated database authentication"
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

if (!jenkins.installState.isSetupComplete()) {
  println "Skipping the Setup Wizard"
  InstallState.INITIAL_SETUP_COMPLETED.initializeState()
}

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

println "Saving all changes"
instance.save()

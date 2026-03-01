// init.groovy.d/03-configure-jenkins-url.groovy
// Sets the Jenkins URL to fix the "Jenkins URL is empty" warning

import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration

def instance = Jenkins.get()
def location = JenkinsLocationConfiguration.get()

def jenkinsUrl = System.getenv('JENKINS_URL_PUBLIC') ?: 'https://jenkins.mgr.suse.de'

location.setUrl(jenkinsUrl)
location.save()

println "--- Jenkins URL set to: ${jenkinsUrl}"

// init.groovy.d/05-add-credentials.groovy
// Automatically adds a secret file credential to Jenkins

import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.CredentialsProvider
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.CredentialsScope
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import hudson.util.Secret

def instance = Jenkins.get()
def credentialId = 'sumaform-secrets'
def credentialDescription = 'Sumaform secrets file'

// Path to the credentials file that will be mounted into the container
def credentialsFilePath = '/var/jenkins_home/secrets/.credentials'

// Check if credential already exists
def domain = Domain.global()
def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
def credentials = CredentialsProvider.lookupCredentials(
        com.cloudbees.plugins.credentials.Credentials.class,
        Jenkins.instance,
        null,
        null
)

def credentialExists = credentials.find { it.id == credentialId }

if (!credentialExists) {
    // Check if the file exists
    def file = new File(credentialsFilePath)
    if (!file.exists()) {
        println "--- WARNING: Credentials file not found at ${credentialsFilePath}"
        return
    }

    try {
        // Read file content as text
        def fileContent = file.text

        // Store as a Secret Text credential
        def secretCredential = new StringCredentialsImpl(
                CredentialsScope.GLOBAL,
                credentialId,
                credentialDescription,
                Secret.fromString(fileContent)
        )

        // Add to credentials store
        store.addCredentials(domain, secretCredential)

        println "--- Secret text credential '${credentialId}' added successfully."

    } catch (Exception e) {
        println "--- ERROR: Failed to create credential: ${e.message}"
        e.printStackTrace()
    }
} else {
    println "--- Credential '${credentialId}' already exists, skipping."
}

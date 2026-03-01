// init.groovy.d/04-create-jobs.groovy
// Creates pipeline job using Jenkins core API (no Job DSL plugin imports needed)

import jenkins.model.Jenkins
import hudson.model.FreeStyleProject
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.GitSCM
import hudson.plugins.git.BranchSpec

def instance = Jenkins.get()
def jobName = 'manager-qe-continuous-build-validation-NUE'

// Only create if it doesn't exist
if (instance.getItemByFullName(jobName) == null) {
    println "--- Creating job '${jobName}'..."
    
    // Create a pipeline job
    def job = instance.createProject(WorkflowJob.class, jobName)
    job.setDescription('Automated build validation pipeline for SUSE Manager QE')
    
    // Configure Git SCM
    def scm = new GitSCM('https://github.com/SUSE/susemanager-ci.git')
    scm.branches = [new BranchSpec('*/master')]
    
    // Configure pipeline definition from SCM
    def definition = new CpsScmFlowDefinition(
        scm,
        'jenkins_pipelines/environments/build-validation/manager-qe-continuous-build-validation-NUE'
    )
    definition.setLightweight(true)
    
    job.setDefinition(definition)
    job.save()
    
    println "--- Job '${jobName}' created successfully."
} else {
    println "--- Job '${jobName}' already exists, skipping."
}

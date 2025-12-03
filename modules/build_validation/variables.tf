variable "ENVIRONMENT_CONFIGURATION" {
  type = any
  description = "Collection of values containing: mac addresses, hypervisor and additional network"
}

variable "PLATFORM_LOCATION_CONFIGURATION" {
  type = any
  description = "Collection of values containing location specific information"
}

variable LOCATION {
  type = string
  description = "Platform location"
}

variable "CUCUMBER_COMMAND" {
  type = string
  default = "export PRODUCT='SUSE-Manager' && run-testsuite"
}

variable "CUCUMBER_GITREPO" {
  type = string
  default = "This is defined in product tfvars"
}

variable "CUCUMBER_BRANCH" {
  type = string
  default = "This is defined in product tfvars"
}

variable "CUCUMBER_RESULTS" {
  type = string
  default = "/root/spacewalk/testsuite"
}
variable "URL_PREFIX" {
  type = string
  default = "Not Used for QE pipeline"
}

variable "MAIL_SUBJECT" {
  type = string
  default = "Set in TFVARS"
}

variable "MAIL_TEMPLATE" {
  type = string
  default = "../mail_templates/mail-template-jenkins.txt"
}

variable "MAIL_SUBJECT_ENV_FAIL" {
  type = string
  default = "Set in TFVARS"
}

variable "MAIL_TEMPLATE_ENV_FAIL" {
  type = string
  default = "../mail_templates/mail-template-jenkins-env-fail.txt"
}

variable "MAIL_FROM" {
  type = string
  default = "galaxy-noise@suse.de"
}

variable "MAIL_TO" {
  type = string
  default = "galaxy-noise@suse.de"
}

#################################################
## End mailer configuration ##
#################################################

// sumaform specific variables
variable "SCC_USER" {
  type = string
}

variable "SCC_PASSWORD" {
  type = string
}

variable "SCC_PTF_USER" {
  type = string
  default = null
  // Not needed for master, as PTFs are only build for SUSE Manager / MLM
}

variable "SCC_PTF_PASSWORD" {
  type = string
  default = null
  // Not needed for master, as PTFs are only build for SUSE Manager / MLM
}

variable "SERVER_CONTAINER_REPOSITORY" {
  type = string
  default = ""
}

variable "PROXY_CONTAINER_REPOSITORY" {
  type = string
  default = ""
}

variable "SERVER_CONTAINER_IMAGE" {
  type = string
  default = ""
}

variable "ZVM_ADMIN_TOKEN" {
  type = string
}

variable "GIT_USER" {
  type = string
  default = null // Not needed for master, as it is public
}

variable "GIT_PASSWORD" {
  type = string
  default = null // Not needed for master, as it is public
}

variable "BASE_OS" {
  type        = string
  description = "Optional override for the server base OS image"
  default     = null
}

variable "PRODUCT_VERSION" {
  type        = string
  description = "Optional override for the product version"
  default     = null
}

variable "base_configurations" {
  type        = map(any)
  description = "Map of base configurations. Mandatory keys: default. Optional: old_sle, new_sle, res, debian, retail, arm, s390."
}
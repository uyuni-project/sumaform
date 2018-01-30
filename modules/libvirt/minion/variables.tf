variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "version" {
  description = "A valid SUSE Manager version (eg. 3.0-nightly, head) see README_ADVANCED.md"
  default = "released"
}

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see the main.tf example file"
  type = "map"
}

variable "activation_key" {
  description = "an Activation Key to be used when onboarding this minion"
  default = "null"
}

variable "for_development_only" {
  description = "whether this host should be pre-configured with settings useful for development, but not necessarily safe in production"
  default = true
}

variable "for_testsuite_only" {
  description = "whether this host should be pre-configured with settings necessary for running the Cucumber testsuite"
  default = false
}

variable "use_unreleased_updates" {
  description = "This adds and updates sle packages from the test repo"
  default = false
}

variable "additional_repos" {
  description = "extra repositories used for installation {label = url}"
  default = {}
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default = []
}

variable "count"  {
  description = "number of hosts like this one"
  default = 1
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default = "/dev/null"
  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  default = []
}

// Provider-specific variables

variable "image" {
  description = "One of: sles11sp3, sles11sp4, sles12, sles12sp1, sles15beta4, centos7"
  type = "string"
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 512
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default = 1
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default = ""
}

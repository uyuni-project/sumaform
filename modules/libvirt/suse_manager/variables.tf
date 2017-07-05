variable "base_configuration" {
  description = "use ${module.base.configuration}, see main.tf.libvirt.example"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "version" {
  description = "One of: 2.1-released,  2.1-nightly, 3.0-nightly, 3.0-released, 3.1-released, 3.1-nightly, head"
  type = "string"
}

variable "database" {
  description = "oracle or postgres for 2.1, postgres or pgpool for 3 and head"
  default = "postgres"
}

variable "iss_master" {
  description = "ISS master server, leave the default for no ISS"
  default = "null"
}

variable "iss_slave" {
  description = "ISS slave server, leave the default for no ISS"
  default = "null"
}

variable "image" {
  description = "Leave default for automatic selection or specify sles12sp2 only if version is 3.0-released or 3.0-nightly"
  default = "default"
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

variable "from_email" {
  description = "email address used as sender for emails"
  default = "null"
}

variable "smt" {
  description = "URL to an SMT server to get packages from"
  default = "null"
}

variable "monitored" {
  description = "whether this host should be monitored via Prometheus"
  default = false
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 4096
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default = 2
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "traceback_email" {
  description = "recipient email address that will receive errors during usage"
  default = "null"
}

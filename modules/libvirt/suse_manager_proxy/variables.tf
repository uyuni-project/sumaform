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

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see see ADVANCED_MAIN_TF.md"
  type = "map"
}

variable "for_development_only" {
  description = "whether this host should be pre-configured with settings useful for development, but not necessarily safe in production"
  default = true
}

variable "use_unreleased_updates" {
  description = "This adds and updates sle packages from the test repo"
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

variable "count"  {
  description = "number of hosts like this one"
  default = 1
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 1024
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

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see libvirt/README.md"
  default = "/dev/null"
  # HACK: "" cannot be used as a default because of https://github\.com/hashicorp/hil/issues/50
}
variable "gpg_keys" {
  description = "gpg keys that you want to add and install to your VMs, see libvirt/README.md"
  default = []
}

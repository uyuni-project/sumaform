variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
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

variable "grains" {
  description = "custom grain string to be added to this host's configuration"
  default = ""
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
  description = "One of: opensuse423, sles11sp4, sles12, sles12sp1, sles12sp2, sles12sp3, sles15beta4, centos7"
  type = "string"
}

variable "flavor" {
  description = "OpenStack flavor"
  default = "m1.tiny"
}

variable "root_volume_size" {
  description = "Size of the root volume in GiB"
  default = 10
}

variable "floating_ips" {
  description = "List of floating IP IDs to associate"
  default = []
}

variable "extra_volume_size" {
  description = "Size of the extra volume, if any, in GiB. Leave default for no extra volume"
  default = 0
}

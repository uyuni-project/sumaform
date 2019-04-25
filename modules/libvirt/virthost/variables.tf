variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "activation_key" {
  description = "an Activation Key to be used when onboarding this minion"
  default = "null"
}

variable "apparmor" {
  description = "whether AppArmor access control should be installed"
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

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default = "/dev/null"
  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  default = []
}

variable "hvm_disk_image" {
  description = "URL to the disk image to use for KVM guests"
  default = "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse423.x86_64.qcow2"
}

// Provider-specific variables

variable "image" {
  description = "One of: sles11sp4, sles12, sles12sp1, sles12sp2, sles12sp3, sles15, centos7"
  type = "string"
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 2048
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default = 3
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default = ""
}

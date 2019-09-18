variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "product_version" {
  description = "A valid SUSE Manager version (eg. 3.2-nightly, head) see README_ADVANCED.md"
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

variable "auto_connect_to_master" {
  description = "whether this minion should automatically connect to the Salt Master upon deployment"
  default = true
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default = false
}

variable "use_os_unreleased_updates" {
  description = "Apply all updates from SUSE Linux Enterprise unreleased (Test) repos"
  default = false
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

variable "ipv6" {
  description = "IPv6 tuning: enable it, accept the RAs"
  type = "map"
  default = {
    enable = true
    accept_ra = true
  }
}

variable "hvm_disk_image" {
  description = "URL to the disk image to use for KVM guests"
  default = "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse151.x86_64.qcow2"
}

variable "hvm_disk_image_hash" {
  description = "Hash of the the disk image, either a URL or the hash itself. See salt's file.managed source_hash documentations"
  default = "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse151.x86_64.qcow2.sha256"
}

// Provider-specific variables

variable "image" {
  description = "One of: sles15, sles15sp1, opensuse150 or opensuse151"
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

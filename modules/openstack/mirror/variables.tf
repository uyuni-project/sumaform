variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
}

variable "swap_file_size" {
  description = "Swap file size in MiB, or 0 for none"
  default = 0
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default = "/dev/null"
  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "ubuntu_distros" {
  description = "List of Ubuntu versions to mirror among 16.04, 18.04, xenial, bionic"
  default = []
}

// Provider-specific variables

variable "floating_ips" {
  description = "List of floating IP IDs to associate"
  default = []
}

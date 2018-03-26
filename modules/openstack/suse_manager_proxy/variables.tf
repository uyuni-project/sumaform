variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "version" {
  description = "One of: 3.0-nightly, 3.0-released, 3.1-released, 3.1-nightly, head"
  type = "string"
}

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see README_ADVANCED.md"
  type = "map"
}

variable "auto_register" {
  description = "whether this proxy should be automatically registered upon deployment"
  default = true
}

variable "download_private_ssl_key" {
  description = "copy SSL certificates from the server upon deployment"
  default = true
}

variable "auto_configure" {
  description = "whether to automatically run configure-proxy.sh upon deployment"
  default = true
}

variable "generate_bootstrap_script" {
  description = "whether to generate a bootstrap script in /pub upon deployment"
  default = true
}

variable "publish_private_ssl_key" {
  description = "whether to copy the private SSL key in /pub upon deployment"
  default = true
}

variable "use_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default = false
}

variable "use_unreleased_updates" {
  description = "Apply all updates from SUSE Linux Enterprise unreleased (Test) repos"
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
  description = "Leave default for automatic selection or specify sles12sp2 only if version is 3.0-released or 3.0-nightly"
  default = "default"
}

variable "flavor" {
  description = "OpenStack flavor"
  default = "m1.small"
}

variable "root_volume_size" {
  description = "Size of the root volume in GiB"
  default = 10
}

variable "floating_ips" {
  description = "List of floating IP IDs to associate"
  default = []
}

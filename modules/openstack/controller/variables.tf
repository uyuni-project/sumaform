variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "git_username" {
  description = "username for GitHub"
  type = "string"
}

variable "git_password" {
  description = "password for GitHub"
  type = "string"
}

variable "git_repo" {
  description = "Git repo clone URL"
  type = "string"
  default = "default"
}

variable "branch" {
  description = "Leave default for automatic selection or specify an existing branch of spacewalk"
  default = "default"
}

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
}

variable "proxy_configuration" {
  description = "use ${module.<PROXY_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
  default = {
    hostname = "null"
  }
}

variable "client_configuration" {
  description = "use ${module.<CLIENT_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
}

variable "minion_configuration" {
  description = "use ${module.<MINION_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
}

variable "minionssh_configuration" {
  description = "use ${module.<MINIONSSH_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
  default = {
    hostname = "null"
  }
}

variable "centos_configuration" {
  description = "use ${module.<CENTOS_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
  default = {
    hostname = "null"
  }
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default = "/dev/null"
  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

// Provider-specific variables

variable "floating_ips" {
  description = "List of floating IP IDs to associate"
  default = []
}

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
  default = {
    hostname = "null"
  }
}

variable "minion_configuration" {
  description = "use ${module.<MINION_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
  default = {
    hostname = "null"
  }
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

variable "ubuntu_configuration" {
  description = "use ${module.<UBUNTU_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
  default = {
    hostname = "null"
  }
}

variable "pxeboot_configuration" {
  description = "use ${module.<PXEBOOT_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
  type = "map"
  default = {
    macaddr = "null"
  }
}

variable "kvmhost_configuration" {
  description = "use ${module.<VIRTHOST_NAME>.configuration}, see main.tf.libvirt-testsuite.example"
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

variable "swap_file_size" {
  description = "Swap file size in MiB, or 0 for none"
  default = 4096
}
variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default = "/dev/null"
  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "git_profiles_repo" {
  description = "URL of git repository with alternate Docker and Kiwi profiles, see README_ADVANCED.md"
  default = "default"
}

// Provider-specific variables

variable "memory" {
  description = "RAM memory in MiB"
  default = 2048
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

variable "cpu_model" {
  description = "Define what CPU model the guest is getting (host-model, host-passthrough or the default)."
  default = ""
}

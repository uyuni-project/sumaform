variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see the main.tf example file"
  type = "map"
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default = "/dev/null"
  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "git_username" {
  description = "username for GitHub"
  type = "string"
  default = "nogit"
}

variable "git_password" {
  description = "password for GitHub"
  type = "string"
  default = "nogit"
}

variable "locust_file" {
  description = "path to a locust_files"
  type = "string"
  default = "salt/locust/simple_locust_example.py"
}

// Provider-specific variables

variable "memory" {
  description = "RAM memory in MiB"
  default = 1024
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default = 1
}


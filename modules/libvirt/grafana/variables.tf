variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  default = "grafana"
}

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see the main.tf example file"
  type = "map"
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
  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

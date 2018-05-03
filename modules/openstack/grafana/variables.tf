variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  default = "grafana"
}

variable "count"  {
  description = "number of hosts like this one"
  default = 1
}

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see the main.tf example file"
  type = "map"
}

variable "locust_configuration" {
  description = "use ${module.<LOCUST_NAME>.configuration}, see README_ADVANCED.md"
  default = { "hostname" = "none" }
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

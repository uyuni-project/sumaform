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

variable "product_version" {
  description = "A valid SUSE Manager version (eg. 3.0-nightly, head) see README_ADVANCED.md"
  default = "released"
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

variable "image" {
  description = "One of: sles12sp2, sles12sp3, sles12sp4"
  type = "string"
  default = "sles12sp4"
}

variable "flavor" {
  description = "OpenStack flavor"
  default = "m1.medium"
}

variable "floating_ips" {
  description = "List of floating IP IDs to associate"
  default = []
}

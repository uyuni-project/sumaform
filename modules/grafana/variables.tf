variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  default     = "grafana"
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
}

variable "server_configuration" {
  description = "use module.<SERVER_NAME>.configuration, see the main.tf example file"
}

variable "locust_configuration" {
  description = "use module.<LOCUST_NAME>.configuration, see README_ADVANCED.md"
  default = {
    "hostname" = "none"
  }
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default     = null
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "product_version" {
  description = "A valid SUSE Manager version (eg. 4.2-nightly, head) see README_ADVANCED.md"
  default     = "released"
}

variable "image" {
  description = "An image name, e.g. sles12sp4 or opensuse154o"
  type        = string
}

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

// Provider-specific variables

variable "running" {
  description = "Whether this host should be turned on or off"
  default     = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = null
}

variable "cpu_model" {
  description = "Define what CPU model the guest is getting (host-model, host-passthrough or the default)."
  default     = ""
}

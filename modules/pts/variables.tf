variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "grafana" {
  description = "whether to deploy a Grafana host monitoring the server"
  default     = true
}

variable "suse_manager_name" {
  description = "hostname, without the domain part"
  default     = "server"
}

variable "minion_name" {
  description = "hostname for the minion instance, without the domain part"
  default     = "minion"
}

variable "locust_name" {
  description = "hostname for the locust instance, without the domain part"
  default     = "locust"
}

variable "pts_system_count" {
  description = "Number of minions"
  default     = "200"
}

variable "grafana_name" {
  description = "hostname for the grafana instance, without the domain part"
  default     = "grafana"
}

// Provider-specific variables

variable "server_mac" {
  description = "a MAC address for the server in the form AA:BB:CC:11:22:22"
  default     = null
}

variable "minion_mac" {
  description = "a MAC address for the minion instance in the form AA:BB:CC:11:22:22"
  default     = null
}

variable "locust_mac" {
  description = "a MAC address for the Locust instance in the form AA:BB:CC:11:22:22"
  default     = null
}

variable "grafana_mac" {
  description = "a MAC address for the Grafana instance in the form AA:BB:CC:11:22:22"
  default     = null
}

variable "cpu_model" {
  description = "Define what CPU model the guest is getting (host-model, host-passthrough or the default)."
  default     = null
}

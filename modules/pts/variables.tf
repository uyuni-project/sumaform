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

variable "server_provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "minion_provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "locust_provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "grafana_provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

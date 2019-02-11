variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "grafana" {
  description = "whether to deploy a Grafana host monitoring the server"
  default = true
}

variable "suse_manager_name" {
  description = "hostname, without the domain part"
  default = "server"
}

variable "minion_name" {
  description = "hostname for the minion instance, without the domain part"
  default = "minion"
}

variable "locust_name" {
  description = "hostname for the locust instance, without the domain part"
  default = "locust"
}

variable "grafana_name" {
  description = "hostname for the grafana instance, without the domain part"
  default = "grafana"
}

variable "pts_system_count" {
  description = "Number of minions"
  default = "200"
}

// Provider-specific variables

variable "server_floating_ips" {
  description = "List of floating IP IDs to associate to the server"
  default = []
}

variable "minion_floating_ips" {
  description = "List of floating IP IDs to associate to the minion instance"
  default = []
}

variable "locust_floating_ips" {
  description = "List of floating IP IDs to associate to the Locust instance"
  default = []
}

variable "grafana_floating_ips" {
  description = "List of floating IP IDs to associate to the Grafana instance"
  default = []
}

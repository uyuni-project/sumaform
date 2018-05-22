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

variable "evil_minions_name" {
  description = "hostname for the evil-minions instance, without the domain part"
  default = "evil-minions"
}

variable "locust_name" {
  description = "hostname for the locust instance, without the domain part"
  default = "locust"
}

variable "grafana_name" {
  description = "hostname for the grafana instance, without the domain part"
  default = "grafana"
}

variable "evil_minions_dumper" {
  description = "if true, it will create a single minion to collect a dump file instead of an evil-minions host"
  default = false
}

// Provider-specific variables

variable "server_mac" {
  description = "a MAC address for the server in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "evil_minions_mac" {
  description = "a MAC address for the evil-minions instance in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "locust_mac" {
  description = "a MAC address for the Locust instance in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "grafana_mac" {
  description = "a MAC address for the Grafana instance in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "monitored" {
  description = "whether the suse manager server should be monitored via Prometheus and Grafana"
  default = false
}

variable "suse_manager_name" {
  description = "hostname, without the domain part"
  type = "string"
  default = "server"
}

variable "evil_minions_name" {
  description = "hostname for the evil-minions instance, without the domain part"
  type = "string"
  default = "evil-minions"
}

variable "locust_name" {
  description = "hostname for the locust instance, without the domain part"
  type = "string"
  default = "locust"
}

variable "grafana_name" {
  description = "hostname for the grafana instance, without the domain part"
  type = "string"
  default = "grafana"
}

variable "suse_manager_mac" {
  description = "a MAC address for the suse manager server in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "evil_minions_mac" {
  description = "a MAC address for the evil-minions instance in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "locust_mac" {
  description = "a MAC address for the locust server in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "grafana_mac" {
  description = "a MAC address for the grafana server in the form AA:BB:CC:11:22:22"
  default = ""
}

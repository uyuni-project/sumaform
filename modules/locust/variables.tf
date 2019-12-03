variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "server_configuration" {
  description = "use module.<SERVER_NAME>.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  default     = "locust"
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default     = null
}

variable "locust_file" {
  description = "path to a locustfile.py"
  default     = "salt/locust/locustfile.py"
}

variable "slave_quantity" {
  description = "number of Locust slaves, set to 0 to disable master-slave mode"
  default     = 0
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

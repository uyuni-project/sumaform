variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "identifier" {
  description = "hostname, without the domain part"
  type        = string
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the modules/libvirt/README.md"
  default     = {}
}

variable "connect_to_base_network" {
  description = "true if you want a card connected to the main network, see README_ADVANCED.md"
  default     = true
}

variable "connect_to_additional_network" {
  description = "true if you want a card connected to the additional network (if any), see README_ADVANCED.md"
  default     = false
}

variable "publicly_accessible" {
  description = "true if you want the RDS to have a public address"
  default = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created."
  default = true
}

variable "engine" {
  description = "RDS engine, by default postgres"
}

variable "engine_version" {
  description = "RDS engine version"
}

variable "db_username" {
  description = "RDS root user name"
  default = "username"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}

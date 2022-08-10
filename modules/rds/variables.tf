variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "rds" 
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the modules/libvirt/README.md"
  default     = {}
}

variable "publicly_accessible" {
  description = "true if you want the RDS to have a public address"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created."
  type        = bool
  default     = true
}

variable "engine" {
  description = "RDS engine, by default postgres "
  default     = "postgres"
}

variable "engine_version" {
  description = "RDS engine version"
  default     = "14.3"
}


variable "db_username" {
  description = "RDS root user name"
  default     = "postgres"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
  default     = "spacewalk"
}

variable "db_certificate" {
  description = "Certificate needed to connect to remote AWS database. https://lightsail.aws.amazon.com/ls/docs/en_us/articles/amazon-lightsail-download-ssl-certificate-for-managed-database "
  default     = "/root/aws.crt"
}

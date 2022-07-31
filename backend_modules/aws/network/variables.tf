variable "region" {
  description = "Region where the instance is created"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone where the instance is created"
  type        = string
}

variable "ssh_allowed_ips" {
  description = "IP addresses allowed to open SSH connections to the public subnet created by this module"
  default     = []
}

variable "name_prefix" {
  description = "A prefix for names of objects created by this module"
  default     = "sumaform"
}

variable "additional_network" {
  description = "Additional network cidr_block (of the form 172.16.x.x/24)"
  default = "172.16.2.0/24"
}

variable "create_network" {
  description = "defined if a new network should be created"
  default     = true
}

variable "create_db_network" {
  description = "defined if a new network should be created"
  default     = false
}

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

variable "private_network" {
  description = "network cidr_block (of the form 172.16.x.x/24)"
  default = "172.16.1.0/24"
}

variable "additional_network" {
  description = "Additional network cidr_block (of the form 172.16.x.x/24)"
  default = "172.16.2.0/24"
}

variable "create_private_network" {
  description = "defined if a new private network should be created"
  default     = true
}

variable "public_subnet_id" {
  description = "optional public subnet id"
  default = null
}

variable "create_additional_network" {
  description = "defined if a new additional private network should be created"
  default     = true
}

variable "create_network" {
  description = "defined if a new network should be created"
  default     = true
}

variable "create_db_network" {
  description = "defined if a new network should be created"
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC where networks should be created in (optional)"
  default     = null
}

variable "location" {
  description = "location where the instance is created"
  type        = string
}

variable "name_prefix" {
  description = "resource name prefix"
  type        = string
}

variable "create_network" {
  description = "defined if a new network should be created"
  type        = bool
  default     = true
}

variable "ssh_allowed_ips" {
  description = "list of ips allowed to ssh"
  type        = list(string)
  default     = []
}

variable "additional_network" {
  description = "Additional network cidr_block (of the form 172.16.x.x/24)"
  type        = string
  default     = "172.16.2.0/24"
}

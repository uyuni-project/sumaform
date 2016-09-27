variable "availability_zone" {
  description = "Availability zone where the instance is created"
  type = "string"
}

variable "ssh_allowed_ips" {
  description = "IP addresses allowed to open SSH connections to the public subnet created by this module"
  default = []
}

variable "name_prefix" {
  description = "A prefix for names of objects created by this module"
  default = "sumaform"
}

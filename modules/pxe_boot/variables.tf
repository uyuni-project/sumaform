variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
}

variable "private_ip" {
  description = "last digit of IP address in private network"
  type        = number
}

variable "private_name" {
  description = "hostname inside the private network"
  type        = string
}

variable "image" {
  description = "an image name, e.g. sles12sp4 or opensuse155o"
  type        = string
}

variable "provider_settings" {
  description = "settings specific to the provider"
  default     = {}
}

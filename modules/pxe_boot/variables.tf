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

variable "image" {
  description = "An image name, e.g. sles12sp4 or opensuse154o"
  type        = string
}

variable "provider_settings" {
  description = "Settings specific to the provider"
  default     = {}
}

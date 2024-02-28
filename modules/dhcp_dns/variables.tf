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

variable "private_hosts" {
  description = "configuration of the various hosts in the private network"
  type        = list(object({
                  private_mac = string
                  private_ip = number
                  private_name = string
                }))
}

variable "image" {
  description = "an image name, e.g. sles12sp5 or opensuse155o"
  type        = string
  default     = "opensuse155o"
}

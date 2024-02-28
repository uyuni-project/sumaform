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

variable "terminals" {
  description = "configuration of the various PXE terminals"
  type        = list(object({
                  id = string
                  hostname = string
                  macaddr = string
                  image = string}))
}

variable "first_terminal_ip" {
  description = "last digit of first terminal IP's address"
  type        = number
  default     = 1
}

variable "image" {
  description = "an image name, e.g. sles12sp4 or opensuse155o"
  type        = string
  default     = "opensuse155o"
}

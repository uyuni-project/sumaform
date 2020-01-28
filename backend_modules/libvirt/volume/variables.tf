variable "volume_name" {
  description = "Disk name"
  type        = string
}

variable "quantity" {
  description = "number of disks to be created"
  type        = number
  default     = 0
}

variable "volume_size" {
  description = "Disk size"
  type        = number
  default     = 0
}

variable "volume_provider_settings" {
  description = "Map of provider-specific settings, see the modules/libvirt/README.md"
  default     = {}
}

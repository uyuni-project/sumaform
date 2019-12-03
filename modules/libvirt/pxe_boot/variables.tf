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

// Provider-specific variables

variable "image" {
  description = "One of: sles11sp4, sles12, sles12sp1, sles12sp2, sles12sp3, sles12sp4, sles15, centos7"
  type        = string
}

variable "memory" {
  description = "RAM memory in MiB"
  default     = 1024
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default     = 1
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default     = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = null
}

variable "additional_disk" {
  description = "disk block definition(s) to be added to this host"
  default     = []
}

variable "cpu_model" {
  description = "Define what CPU model the guest is getting (host-model, host-passthrough or the default)."
  default     = null
}

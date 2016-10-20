variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "image" {
  description = "name of the base OS image, see modules/libvirt/images"
  type = "string"
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}

variable "count"  {
  description = "number of hosts like this one"
  default = 1
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 512
}

variable "vcpu" {
  description = "number of virtual CPUs"
  default = 1
}

variable "running" {
  description = "whether this host should be turned on or off"
  default = true
}

variable "pool" {
  description = "libvirt storage pool name for this host's disk"
  default = "default"
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host"
  default = ""
}

variable "mac" {
  description = "a MAC address, in the form AA:BB:CC:11:22:22, only if bridge is specified"
  default = ""
}

variable "grains" {
  description = "custom grain string to be added to this host's configuration"
  default = ""
}

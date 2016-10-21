variable "image_id" {
  description = "${module.opensuse421.id}, see modules/libvirt/README.md"
  type = "string"
}

variable "cc_username" {
  description = "Username for the Customer Center"
  type = "string"
}

variable "cc_password" {
  description = "Password for the Customer Center"
  type = "string"
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default = true
}

variable "main_pool" {
  description = "libvirt storage pool name for this host's main disk"
  default = "default"
}

variable "data_pool" {
  description = "libvirt storage pool name for this host's data disk"
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

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}

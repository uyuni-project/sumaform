variable "running" {
  description = "Whether this host should be turned on or off"
  default = true
}

variable "image" {
  description = "Name of the base OS image, see main.tf.libvirt.example"
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

variable "libvirt_main_pool" {
  description = "libvirt storage pool name for this host's main disk"
  default = "default"
}

variable "libvirt_data_pool" {
  description = "libvirt storage pool name for this host's data disk"
  default = "default"
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}

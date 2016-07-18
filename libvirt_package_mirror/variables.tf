variable "image" {}

variable "libvirt_main_pool" {
  default = "default"
}

variable "libvirt_data_pool" {
  default = "default"
}

variable "domain" {
  default = "tf.local"
}

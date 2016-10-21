variable "domain" {
  description = "domain name for hosts in this network"
  default = "tf.local"
}

variable "addresses" {
  description = "IPv4 address range to be used in this network"
  default = "192.168.127.0/24"
}

variable "name_prefix" {
  description = "A prefix for names of objects created by this module"
  default = ""
}
